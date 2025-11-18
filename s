Thanks for the screenshot — now it’s 100% clear what happened:

👉 Your tabs are not visible at all because the page currently doesn’t contain ANY tab markup.
Right now your Details page is rendering only the existing summary header + fields table — the tab navigation bar isn’t present, so of course you can’t switch tabs.

Let’s fix that by updating the MVC 5 Razor view so the UI shows:

Tab 1: Configuration (your current content)

Tab 2: Migration Log (new table with pagination + filtering)


I’ll give you fully working Bootstrap 3 markup that will show the tabs correctly.


---

✅ Step 1 — Insert Bootstrap-3 Tab Markup

Replace your current content wrapper with this structure:

@model RemapDetailsViewModel

<!-- TAB HEADERS -->
<ul class="nav nav-tabs" id="remapTabs">
    <li class="active">
        <a href="#configTab" data-toggle="tab">Configuration</a>
    </li>
    <li>
        <a href="#logTab" data-toggle="tab">Migration Log</a>
    </li>
</ul>

<!-- TAB CONTENT -->

<div class="tab-content" style="margin-top:20px;">

    <!-- CONFIG TAB -->
    <div class="tab-pane fade in active" id="configTab">
        @* YOUR EXISTING SUMMARY + FIELD RULES *@
        @Html.Partial("_RemapConfig", Model)
    </div>

    <!-- LOG TAB -->
    <div class="tab-pane fade" id="logTab">
        @Html.Partial("_RemapMigrationLog")
    </div>

</div>

✔ This will display the two tabs
✔ Clicking switches between them (Bootstrap 3 behavior)


---

✅ Step 2 — Create Partial View for Tab 1 (Configuration)

Create file:

Views/Remap/_RemapConfig.cshtml

Paste your existing HTML (summary header + table of fields).

Nothing changes here — you just move it into its own partial.


---

✅ Step 3 — Create Partial View for Tab 2 (Migration Log)

Create file:

Views/Remap/_RemapMigrationLog.cshtml

Use this:

<div class="row">
    <div class="col-md-3">
        <select id="log-status-filter" class="form-control">
            <option value="All">All</option>
            <option value="Completed">Completed</option>
            <option value="Error">Error</option>
            <option value="Processing">Processing</option>
        </select>
    </div>
</div>

<br />

<table class="table table-bordered table-striped" id="log-table">
    <thead>
        <tr>
            <th>DocumentKey</th>
            <th>SiteCode</th>
            <th>Status</th>
            <th>ModifiedOn</th>
        </tr>
    </thead>
    <tbody></tbody>
</table>

<ul id="log-pager" class="pagination"></ul>


---

✅ Step 4 — Add the JavaScript (MVC 5 + jQuery)

At the bottom of the Details Page:

@section Scripts {
<script>
$(function () {

    var remapId = @Model.RemapId;
    var currentPage = 1;
    var pageSize = 25;
    var currentStatus = "All";

    // Load log only when log tab is clicked first time
    $('a[href="#logTab"]').on('shown.bs.tab', function () {
        if ($('#log-table tbody').children().length === 0) {
            loadLog(1);
        }
    });

    $('#log-status-filter').on('change', function () {
        currentStatus = $(this).val();
        loadLog(1);
    });

    function loadLog(page) {
        currentPage = page;

        $.getJSON('@Url.Action("MigrationLog", "Remap")', {
            remapId: remapId,
            page: currentPage,
            pageSize: pageSize,
            status: currentStatus
        }).done(function (data) {

            var $tbody = $('#log-table tbody').empty();

            $.each(data.Items, function (i, row) {
                var html = '<tr>' +
                    '<td>' + row.DocumentKey + '</td>' +
                    '<td>' + row.SiteCode + '</td>' +
                    '<td>' + row.Status + '</td>' +
                    '<td>' + row.ModifiedOn + '</td>' +
                    '</tr>';

                $tbody.append(html);
            });

            renderPager(data.TotalCount, data.Page, data.PageSize);
        });
    }

    function renderPager(totalCount, page, pageSize) {
        var totalPages = Math.max(1, Math.ceil(totalCount / pageSize));
        var $pager = $('#log-pager').empty();

        for (var p = 1; p <= totalPages; p++) {
            var li = $('<li>').toggleClass('active', p === page);
            var a = $('<a href="#">').text(p).click((function (p2) {
                return function (e) {
                    e.preventDefault();
                    loadLog(p2);
                };
            })(p));

            li.append(a);
            $pager.append(li);
        }
    }

});
</script>
}


---

✅ Step 5 — Confirm Bootstrap 3 Is Loaded Correctly

In your _Layout.cshtml, ensure:

@Scripts.Render("~/bundles/jquery")
@Scripts.Render("~/bundles/bootstrap")

Bootstrap 3 requires:

jQuery BEFORE bootstrap.js

data-toggle="tab" attribute (NOT Bootstrap 5’s data-bs-toggle)



---

🎉 Result

You will now get:

✔ Tabs appear

✔ You can switch between Configuration and Log

✔ Migration Log loads via AJAX

✔ Pagination works

✔ Status filtering works

✔ Fully compatible with MVC 5 + Bootstrap 3


---

If you want, you can send your current Details.cshtml, and I will integrate all this directly into your file.