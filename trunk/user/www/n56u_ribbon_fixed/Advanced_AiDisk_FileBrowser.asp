<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - <#menu5_15_1#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/engage.itoggle.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/bootstrap/js/engage.itoggle.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/itoggle.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script>
var $j = jQuery.noConflict();

$j(document).ready(function() {
    init_itoggle('filebrowser_enabled', change_filebrowser_enabled);
    change_filebrowser_enabled();
});

</script>

<script>
var lan_ipaddr = '<% nvram_get_x("", "lan_ipaddr_t"); %>';
<% login_state_hook(); %>

function initial(){
    show_banner(1);
    show_menu(5,13,1);
    show_footer();
}

function applyRule(){
//    if(validForm()){
        showLoading();
        
        document.form.action_mode.value = " Apply ";
        document.form.current_page.value = "/Advanced_AiDisk_FileBrowser.asp";
        document.form.next_page.value = "";
        
        document.form.submit();
//    }
}

function done_validating(action){
    refreshpage();
}

function change_filebrowser_enabled(){
    var v = document.form.filebrowser_enabled[0].checked;
    showhide_div("filebrowser_port", v);
}

function on_filebrowser_link(){
    var window_params="toolbar=yes,location=yes,directories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes,copyhistory=no,width=800,height=600";
	var rpc_url="http://" + lan_ipaddr + ":" + document.form.filebrowser_port.value;
	window_rpc = window.open(rpc_url, "FileBrowser", window_params);
	window_rpc.focus();
}

</script>

</head>

<body onload="initial();" onunLoad="return unload_body();">

<div class="wrapper">
    <div class="container-fluid" style="padding-right: 0px">
        <div class="row-fluid">
            <div class="span3"><center><div id="logo"></div></center></div>
            <div class="span9" >
                <div id="TopBanner"></div>
            </div>
        </div>
    </div>

    <div id="Loading" class="popup_bg"></div>

    <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

    <form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">

    <input type="hidden" name="current_page" value="Advanced_AiDisk_FileBrowser.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="ExtraApplications;">
    <input type="hidden" name="group_id" value="">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">

    <div class="container-fluid">
        <div class="row-fluid">
            <div class="span3">
                <!--Sidebar content-->
                <!--=====Beginning of Main Menu=====-->
                <div class="well sidebar-nav side_nav" style="padding: 0px;">
                    <ul id="mainMenu" class="clearfix"></ul>
                    <ul class="clearfix">
                        <li>
                            <div id="subMenu" class="accordion"></div>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="span9">
                <!--Body content-->
                <div class="row-fluid">
                    <div class="span12">
                        <div class="box well grad_colour_dark_blue">
                            <h2 class="box_head round_top"><#menu5_15_1#></h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <span style="color:#FF0000;" class=""></span></div>

                                    <table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th colspan="4" style="background-color: #E3E3E3;">Status</th>
                                        </tr>
                                        <tr id="filebrowser_enable_tr" > 
                                            <th width="50%">
                                                <a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,17,13);"><#StorageEnableFileBrowser#></a>
                                            </th>
                                        </th>
                                            <td>
                                                    <div class="main_itoggle">
                                                    <div id="filebrowser_enabled_on_of">
                                                        <input type="checkbox" id="filebrowser_enabled_fake" <% nvram_match_x("", "filebrowser_enabled", "1", "value=1 checked"); %><% nvram_match_x("", "filebrowser_enabled", "0", "value=0"); %> >
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="filebrowser_enabled" id="filebrowser_enabled_1" onclick="change_filebrowser_enabled();" <% nvram_match_x("", "filebrowser_enabled", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="filebrowser_enabled" id="filebrowser_enabled_0" onclick="change_filebrowser_enabled();" <% nvram_match_x("", "filebrowser_enabled", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr id="filebrowser_port"> <th width="50%"><#StoragePortFileBrowser#></th>
                                            <td>
                                                <input type="text" maxlength="64" class="input" size="64" name="filebrowser_port" value="<% nvram_get_x("","filebrowser_port"); %>" onkeypress="return is_number(this,event);"/>
                                            </td>
                                            <td>
                                               <a href="javascript:on_filebrowser_link();" id="web_aria_link">FileBrowser</a>
                                            </td>
                                        </tr>
                                    </table>
                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <td style="border-top: 0 none;">
                                                <center><input class="btn btn-primary" style="width: 219px" onclick="applyRule();" type="button" value="<#CTL_apply#>" /></center>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    </form>

    <div id="footer"></div>
</div>
</body>
</html>