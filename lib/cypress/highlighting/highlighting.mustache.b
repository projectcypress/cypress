<!DOCTYPE html>
<html>
<head>
        <script type="text/javascript">
         $("document").ready(function() {
            var measureTeamplate = $("#MustacheTemplate").html();

        </script>
</head>
    <body>
        <script type="text/HanldeBarTemplate" id="measureTemplate"></script>
            <div class="measureDataWrapper">
                {{#measures}}
                    {{cms_id}}
                    {{#component}}
                        <div>{{cms_id}}</div>
                    {{/component}}
                    {{#component}}
                        {{#green}} {{cms_id}} {{/green}}
                    {{/component}}
                {{/measures}}
            </div>
        </script>
        <div id="container"></div>
    </body>
</html>
