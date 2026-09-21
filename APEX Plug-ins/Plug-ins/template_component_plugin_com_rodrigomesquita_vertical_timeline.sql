prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2026.03.30'
,p_release=>'26.1.3'
,p_default_workspace_id=>20575405984736225816
,p_default_application_id=>82233
,p_default_id_offset=>0
,p_default_owner=>'WKSP_ARCHI04'
);
end;
/
 
prompt APPLICATION 82233 - APEX Plug-Ins
--
-- Application Export:
--   Application:     82233
--   Name:            APEX Plug-Ins
--   Date and Time:   12:55 Monday September 21, 2026
--   Exported By:     ARCHIPATEL2632004@GMAIL.COM
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 59394843033990757846
--   Manifest End
--   Version:         26.1.3
--   Instance ID:     63113759365424
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/template_component/com_rodrigomesquita_vertical_timeline
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(59394843033990757846)
,p_plugin_type=>'TEMPLATE COMPONENT'
,p_theme_id=>nvl(wwv_flow_application_install.get_theme_id, '')
,p_name=>'COM.RODRIGOMESQUITA.VERTICAL_TIMELINE'
,p_display_name=>'Vertical Timeline'
,p_apexlang_name=>'verticalTimeline'
,p_supported_component_types=>'REPORT'
,p_css_file_urls=>'#PLUGIN_FILES#vertical_timeline#MIN#.css'
,p_partial_template=>wwv_flow_string.join(wwv_flow_t_varchar2(
'{if APEX$IS_LAZY_LOADING/}',
'  <div><span aria-hidden="true" class="fa fa-refresh fa-2x fa-anim-spin"></span></div>',
'{else/}',
'    <span class="fa #VT_ICON# vt-icon" aria-hidden="true"></span>',
'       <div class="vt-header">',
'            <div class="vt_header_text">#VT_TEXT#<br> #VT_SUBTEXT#</div>',
'            <div>{if APEX$HAS_ACTION_BUTTONS/} #MENU_ACTION# {endif/}</div>',
'       </div>',
'    <div class="vt-item-text">#VT_DESC#</div>',
'{endif/}'))
,p_default_escape_mode=>'HTML'
,p_translate_this_template=>false
,p_api_version=>1
,p_report_body_template=>'<ul class="vt-container">#APEX$ROWS#</ul>'
,p_report_row_template=>'<li #APEX$ROW_IDENTIFICATION#>#APEX$PARTIAL#</li>'
,p_report_placeholder_count=>3
,p_standard_attributes=>'REGION_TEMPLATE'
,p_substitute_attributes=>true
,p_version_scn=>'SH256:3mBosyz7iImnDOzeXm7aIXxM0fxcCunuJpKqIb9Bi0c'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>',
'  Oracle APEX Template Component Plugin <STRONG>Vertical Timeline<STRONG>',
'</p>',
'<p>',
'  Author: <code>Rodrigo Mesquita</code><br/>',
'  E-mail: <code>rodrigomesquita.ti@gmail.com</code><br/>',
'  X: <code>@mesquitarod</code><br/>',
'  Plugin home page: <code>https://github.com/rodrigomesquitaorclapex/verticalTimeline</code>',
'  License: Licensed under the MIT (LICENSE.txt) license.',
'</p>'))
,p_version_identifier=>'1.0'
,p_about_url=>'https://github.com/rodrigomesquitaorclapex/verticalTimeline'
,p_files_version=>2461253075324
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(59394843762948757914)
,p_plugin_id=>wwv_flow_imp.id(59394843033990757846)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>3
,p_static_id=>'VT_DESC'
,p_prompt=>'Description'
,p_apexlang_name=>'description'
,p_attribute_type=>'SESSION STATE VALUE'
,p_is_required=>false
,p_escape_mode=>'HTML'
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(59394844092579757914)
,p_plugin_id=>wwv_flow_imp.id(59394843033990757846)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>4
,p_static_id=>'VT_ICON'
,p_prompt=>'Icon Class'
,p_apexlang_name=>'iconClass'
,p_attribute_type=>'SESSION STATE VALUE'
,p_is_required=>false
,p_escape_mode=>'HTML'
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(59394844509622757914)
,p_plugin_id=>wwv_flow_imp.id(59394843033990757846)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>2
,p_static_id=>'VT_SUBTEXT'
,p_prompt=>'Subtext'
,p_apexlang_name=>'subtext'
,p_attribute_type=>'SESSION STATE VALUE'
,p_is_required=>false
,p_escape_mode=>'HTML'
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(59394844891606757915)
,p_plugin_id=>wwv_flow_imp.id(59394843033990757846)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>1
,p_static_id=>'VT_TEXT'
,p_prompt=>'Text'
,p_apexlang_name=>'text'
,p_attribute_type=>'SESSION STATE VALUE'
,p_is_required=>false
,p_escape_mode=>'HTML'
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_act_template(
 p_id=>wwv_flow_imp.id(59394856777970795026)
,p_plugin_id=>wwv_flow_imp.id(59394843033990757846)
,p_name=>'Menu'
,p_apexlang_name=>'menu'
,p_static_id=>'menu'
,p_type=>'MENU'
,p_template=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<button class="t-Button t-Button--noLabel  t-Button--icon t-Button--tiny t-Button--link" {if IS_DISABLED/}disabled{endif/} type="button" data-menu="#MENU_ID#">',
'    <span class="rw-Button-icon oj-ux-ico-overflow-h" aria-hidden="true"></span>',
'    <span class="t-Icon fa fa-bars" aria-hidden="true"></span>',
'</button> #MENU#'))
);
wwv_flow_imp_shared.create_plugin_act_position(
 p_id=>wwv_flow_imp.id(59394856270755789664)
,p_plugin_id=>wwv_flow_imp.id(59394843033990757846)
,p_name=>'Menu'
,p_static_id=>'MENU_ACTION'
,p_apexlang_name=>'menu'
,p_display_sequence=>10
,p_type=>'LINK'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E76742D69636F6E207B0A202020206C6566743A202D343370783B0A20202020746F703A203270783B0A20202020636F6C6F723A20766172282D2D752D636F6C6F722D32293B0A7D0A2E76742D636F6E7461696E6572207B0A202077696474683A206175';
wwv_flow_imp.g_varchar2_table(2) := '746F3B0A20206D617267696E3A206175746F3B0A2020646973706C61793A20626C6F636B3B0A2020706F736974696F6E3A2072656C61746976653B0A20206D61782D77696474683A20313030253B0A7D0A0A2E76742D636F6E7461696E657220207B0A20';
wwv_flow_imp.g_varchar2_table(3) := '2070616464696E673A20333070783B0A2020646973706C61793A20696E6C696E652D626C6F636B3B0A7D0A0A2E76742D636F6E7461696E6572206C69207B0A202020206C6973742D7374796C653A206E6F6E653B0A202020206D617267696E3A20617574';
wwv_flow_imp.g_varchar2_table(4) := '6F3B0A202020206D617267696E2D6C6566743A206175746F3B0A202020206D696E2D6865696768743A20353070783B0A20202020626F726465722D6C6566743A203130707820736F6C696420766172282D2D752D636F6C6F722D32293B0A202020207061';
wwv_flow_imp.g_varchar2_table(5) := '6464696E673A203020302030707820333070783B0A20202020706F736974696F6E3A2072656C61746976653B0A202020206D617267696E2D72696768743A206175746F3B0A7D0A0A2E76742D636F6E7461696E657220206C693A6C6173742D6368696C64';
wwv_flow_imp.g_varchar2_table(6) := '207B0A2020626F726465722D6C6566743A20303B0A20206C6566743A20313070783B0A20206D617267696E2D72696768743A20313070783B0A7D0A0A2E76742D636F6E7461696E6572206C693A3A6265666F7265207B0A20202020706F736974696F6E3A';
wwv_flow_imp.g_varchar2_table(7) := '206162736F6C7574653B0A202020206C6566743A202D323070783B0A20202020746F703A202D3570783B0A20202020636F6E74656E743A202220223B0A20202020626F726465723A2033707820736F6C696420766172282D2D752D636F6C6F722D32293B';
wwv_flow_imp.g_varchar2_table(8) := '0A20202020626F726465722D7261646975733A20353030253B0A202020206261636B67726F756E643A20236666666666663B0A202020206865696768743A20333070783B0A2020202077696474683A20333070783B0A7D0A0A2E76742D636F6E7461696E';
wwv_flow_imp.g_varchar2_table(9) := '6572206C69202E76742D686561646572207B0A2020636F6C6F723A20766172282D2D752D636F6C6F722D32293B0A2020706F736974696F6E3A2072656C61746976653B0A2020666F6E742D73697A653A20313270783B0A2020746F703A202D323570783B';
wwv_flow_imp.g_varchar2_table(10) := '0A2020646973706C61793A20666C65783B0A7D0A0A2E76745F6865616465725F74657874207B0A2020202077696474683A2031363070783B0A7D0A0A2E76742D6974656D2D74657874207B0A2020636F6C6F723A20766172282D2D75742D6669656C642D';
wwv_flow_imp.g_varchar2_table(11) := '6C6162656C2D746578742D636F6C6F72293B0A2020746F703A202D323570783B0A2020706F736974696F6E3A2072656C61746976653B0A7D0A0A0A0A0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(59394854651352779563)
,p_plugin_id=>wwv_flow_imp.id(59394843033990757846)
,p_file_name=>'vertical_timeline.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E76742D69636F6E207B6C6566743A202D343370783B746F703A203270783B636F6C6F723A20766172282D2D752D636F6C6F722D32293B7D2E76742D636F6E7461696E6572207B77696474683A206175746F3B6D617267696E3A206175746F3B64697370';
wwv_flow_imp.g_varchar2_table(2) := '6C61793A20626C6F636B3B706F736974696F6E3A2072656C61746976653B6D61782D77696474683A20313030253B7D2E76742D636F6E7461696E657220207B70616464696E673A20333070783B646973706C61793A20696E6C696E652D626C6F636B3B7D';
wwv_flow_imp.g_varchar2_table(3) := '2E76742D636F6E7461696E6572206C69207B6C6973742D7374796C653A206E6F6E653B6D617267696E3A206175746F3B6D617267696E2D6C6566743A206175746F3B6D696E2D6865696768743A20353070783B626F726465722D6C6566743A2031307078';
wwv_flow_imp.g_varchar2_table(4) := '20736F6C696420766172282D2D752D636F6C6F722D32293B70616464696E673A203020302030707820333070783B706F736974696F6E3A2072656C61746976653B6D617267696E2D72696768743A206175746F3B7D2E76742D636F6E7461696E65722020';
wwv_flow_imp.g_varchar2_table(5) := '6C693A6C6173742D6368696C64207B626F726465722D6C6566743A20303B6C6566743A20313070783B6D617267696E2D72696768743A20313070783B7D2E76742D636F6E7461696E6572206C693A3A6265666F7265207B706F736974696F6E3A20616273';
wwv_flow_imp.g_varchar2_table(6) := '6F6C7574653B6C6566743A202D323070783B746F703A202D3570783B636F6E74656E743A202220223B626F726465723A2033707820736F6C696420766172282D2D752D636F6C6F722D32293B626F726465722D7261646975733A20353030253B6261636B';
wwv_flow_imp.g_varchar2_table(7) := '67726F756E643A20236666666666663B6865696768743A20333070783B77696474683A20333070783B7D2E76742D636F6E7461696E6572206C69202E76742D686561646572207B636F6C6F723A20766172282D2D752D636F6C6F722D32293B706F736974';
wwv_flow_imp.g_varchar2_table(8) := '696F6E3A2072656C61746976653B666F6E742D73697A653A20313270783B746F703A202D323570783B646973706C61793A20666C65783B7D2E76745F6865616465725F74657874207B77696474683A2031363070783B7D2E76742D6974656D2D74657874';
wwv_flow_imp.g_varchar2_table(9) := '207B636F6C6F723A20766172282D2D75742D6669656C642D6C6162656C2D746578742D636F6C6F72293B746F703A202D323570783B706F736974696F6E3A2072656C61746976653B7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(59394854914275779565)
,p_plugin_id=>wwv_flow_imp.id(59394843033990757846)
,p_file_name=>'vertical_timeline.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
