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
--     PLUGIN: 44851197089831115000
--   Manifest End
--   Version:         26.1.3
--   Instance ID:     63113759365424
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/uc_message_actions
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(44851197089831115000)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'UC_MESSAGE_ACTIONS'
,p_display_name=>'UC - Message Actions'
,p_apexlang_name=>'ucMessageActions'
,p_category=>'EXECUTE'
,p_javascript_file_urls=>'#PLUGIN_FILES#js/script#MIN#.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function render',
'  ( p_dynamic_action apex_plugin.t_dynamic_action',
'  , p_plugin         apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_dynamic_action_render_result',
'as',
'    l_result apex_plugin.t_dynamic_action_render_result;',
'',
'    --general attributes',
'    l_action               p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_message_type         p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'    l_message              p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'    l_js_code              p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;',
'    l_escape               boolean                            := p_dynamic_action.attribute_05 = ''Y'';',
'    l_autodismiss          boolean                            := p_dynamic_action.attribute_08 = ''Y'';',
'    l_clear_items          apex_t_varchar2                    := case when p_dynamic_action.attribute_11 is not null then apex_string.split(p_dynamic_action.attribute_11, '','') else apex_t_varchar2() end;',
'',
'    -- Javascript Initialization Code',
'    l_init_js_fn           varchar2(32767)                    := nvl(apex_plugin_util.replace_substitutions(p_dynamic_action.init_javascript_code), ''undefined'');',
'',
'    -- error configuration',
'    l_err_display_location apex_t_varchar2                    := apex_string.split(nvl(p_dynamic_action.attribute_06, ''inline:page''), '':'');',
'    l_err_associated_item  p_dynamic_action.attribute_07%type := p_dynamic_action.attribute_07;',
'    l_clear_errors         boolean                            := p_dynamic_action.attribute_10 = ''Y'';',
'',
'    -- success configuration',
'    l_duration             p_dynamic_action.attribute_09%type := p_dynamic_action.attribute_09;',
'',
'    -- message types to clear',
'    l_clear_success        boolean                            := instr(nvl(p_dynamic_action.attribute_12,'' ''), ''success'') > 0;',
'    l_clear_error          boolean                            := instr(nvl(p_dynamic_action.attribute_12,'' ''), ''error''  ) > 0;',
'    l_hide_after           pls_integer                        := p_dynamic_action.attribute_13;',
'',
'',
'begin',
'    -- standard debugging intro, but only if necessary',
'    if apex_application.g_debug and substr(:DEBUG,6) >= 6',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action',
'          );',
'    end if;',
'',
'    -- create a JS function call passing all settings as a JSON object',
'    --',
'    --   UC.message.action(this, {',
'    --       "message": function() {',
'    --           return (this.data);',
'    --       },',
'    --       "actionType": "showPageSuccess",',
'    --       "escape": true,',
'    --       "config": {',
'    --           "duration": "3000"',
'    --       }',
'    --   });',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'',
'    if l_action in (''show-page-success'', ''show-error'')',
'    then',
'        if l_message_type =  ''static''',
'        then',
'            apex_json.write(''message'', l_message);',
'        else',
'            apex_json.write_raw',
'              ( p_name  => ''message''',
'              , p_value => case l_message_type',
'                               when ''javascript-expression'' then',
'                                  ''function(){return ('' || l_js_code || '');}''',
'                               when ''javascript-function-body'' then',
'                                   ''function(){'' || l_js_code || ''}''',
'                           end',
'              );',
'        end if;',
'    end if;',
'',
'    case l_action',
'        when ''show-page-success'' then',
'            apex_json.write(''actionType'' , ''showPageSuccess'');',
'            apex_json.write(''escape''     , l_escape);',
'',
'            apex_json.open_object(''config'');',
'            apex_json.write(''autoDismiss'', l_autodismiss);',
'            if l_autodismiss then',
'                apex_json.write(''duration'', l_duration * 1000);',
'            end if;',
'            apex_json.close_object;',
'',
'        when ''hide-page-success'' then',
'            apex_json.write(''actionType''  , ''hidePageSuccess'');',
'',
'        when ''show-error'' then',
'            apex_json.write(''actionType''  , ''showError'');',
'            apex_json.write(''escape''      , l_escape);',
'',
'            apex_json.open_object(''config'');',
'            apex_json.write(''autoDismiss'' , l_autodismiss);',
'',
'            if l_autodismiss',
'            then',
'                apex_json.write(''duration'', l_duration * 1000);',
'            end if;',
'',
'            apex_json.write(''location''    , l_err_display_location);',
'            apex_json.write(''pageItem''    , trim(both '','' from replace(l_err_associated_item, '' '','''')));',
'            apex_json.write(''clearErrors'' , l_clear_errors);',
'            apex_json.close_object;',
'',
'        when ''clear-errors'' then',
'            apex_json.write(''actionType''  , ''clearErrors'');',
'            apex_json.write(''pageItems''   , l_clear_items);',
'        when ''clear-message'' then',
'            apex_json.write(''actionType''  , ''clearMessage'');',
'            apex_json.write(''clearSuccess'', l_clear_success);',
'            apex_json.write(''clearError''  , l_clear_error);',
'            apex_json.write(''hideAfter''   , l_hide_after * 1000);',
'    end case;',
'',
'    apex_json.close_object;',
'',
'    l_result.javascript_function := ''function(){uc.message.action(this, '' || apex_json.get_clob_output || '', ''|| l_init_js_fn || '');}'';',
'',
'    apex_json.free_output;',
'',
'    return l_result;',
'end render;',
''))
,p_api_version=>1
,p_render_function=>'render'
,p_standard_attributes=>'INIT_JAVASCRIPT_CODE'
,p_substitute_attributes=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The <strong>UC - Message Actions</strong> dynamic action plug-in is an easy and declarative way to deal with APEX success and error messages. It can show errors inline with fields and in notifications, as well as showing page level messages that l'
||'ook the same as regular APEX page notifications. Internally we use the same Javascript API that APEX provides to show these messages.</p>',
'<p>The message can be a static string with optional page item substitutions, or derived from a Javascript expression or function.</p>',
'<p>You also have control over how escaping should be performed on the message. Either entirely, or only for certain page items if your message contains HTML markup.</p>'))
,p_version_identifier=>'23.1.0'
,p_about_url=>'https://plug-ins-pro.com'
,p_files_version=>395
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851197359398114999)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_static_id=>'attribute_01'
,p_prompt=>'Action'
,p_apexlang_name=>'action'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'show-page-success'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>The action to be performed.</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851199785107114998)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_display_sequence=>50
,p_display_value=>'Auto Dismiss Message(s)'
,p_return_value=>'clear-message'
,p_apexlang_name=>'autoDismissMessageS'
,p_help_text=>'<p>Select this option (and execute it on Page Load) to automatically dismiss success/error messages after a specified time.</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851199269898114998)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_display_sequence=>40
,p_display_value=>'Clear Errors'
,p_return_value=>'clear-errors'
,p_apexlang_name=>'clearErrors'
,p_help_text=>'<p>Clears all current error notifications.</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851198293205114999)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_display_sequence=>20
,p_display_value=>'Hide Page Success'
,p_return_value=>'hide-page-success'
,p_apexlang_name=>'hidePageSuccess'
,p_help_text=>'<p>Hides the success notification if one is present.</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851198826608114998)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_display_sequence=>30
,p_display_value=>'Show Error'
,p_return_value=>'show-error'
,p_apexlang_name=>'showError'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Displays an error notification.</p>',
'<p>It can be displayed on page, targeted to a specific item, or both.</p>',
'<p>By default, error notifications are added to a stack, which means you can call this action multiple times to display various errors. If you wish to clear the stack and only display this error, make sure to call the "Clear Errors" action first.</p>'))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851197792859114999)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_display_sequence=>10
,p_display_value=>'Show Page Success'
,p_return_value=>'show-page-success'
,p_apexlang_name=>'showPageSuccess'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Displays a success notification.</p>',
'<p>Note that if one already exists, it will be replaced.</p>'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851200246617114998)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_static_id=>'attribute_02'
,p_prompt=>'Message Type'
,p_apexlang_name=>'messageType'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'static'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'show-page-success,show-error'
,p_lov_type=>'STATIC'
,p_help_text=>'<p>The source type of the message to be displayed.</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851201220985114998)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851200246617114998)
,p_display_sequence=>20
,p_display_value=>'JavaScript Expression'
,p_return_value=>'javascript-expression'
,p_apexlang_name=>'javascriptExpression'
,p_help_text=>'<p>A JavaScript Expression</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851201732542114997)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851200246617114998)
,p_display_sequence=>30
,p_display_value=>'JavaScript Function Body'
,p_return_value=>'javascript-function-body'
,p_apexlang_name=>'javascriptFunctionBody'
,p_help_text=>'<p>A JavaScript function body returning a string</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851200692678114998)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851200246617114998)
,p_display_sequence=>10
,p_display_value=>'Static Text'
,p_return_value=>'static'
,p_apexlang_name=>'staticText'
,p_help_text=>'<p>A static value. This value can also reference page items.</p>'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851202219102114997)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_static_id=>'attribute_03'
,p_prompt=>'Message'
,p_apexlang_name=>'message'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>true
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851200246617114998)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'static'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The message to be displayed.</p>',
'<p>You can reference any page item by using the "&PAGE_ITEM." format. To escape the page item value, either set "Escape Special Characters" to "Yes", or use the "&PAGE_ITEM!HTML." substitution format.</p>',
'<p><b>Note: </b> The substitution will be done in the browser, with the current page item values.</p>'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851202593042114997)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_static_id=>'attribute_04'
,p_prompt=>'JavaScript Code'
,p_apexlang_name=>'javascriptCode'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851200246617114998)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'javascript-expression,javascript-function-body'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<h4>JavaScript Expression</h4>',
'<pre>apex.item(''P1_COUNT'').getValue() + " records added"</pre>',
'',
'<h4>JavaScript Function Body</h4>',
'<pre>var count = apex.item(''P1_COUNT'').getValue();',
'return count + " record" + (count != 1 ? "s" : "") + " added";',
'</pre>'))
,p_help_text=>'<p>JavaScript Code resulting in a string.</p>'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851202994194114997)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_static_id=>'attribute_05'
,p_prompt=>'Escape Special Characters'
,p_apexlang_name=>'escapeSpecialCharacters'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'show-page-success,show-error'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>To prevent Cross-Site Scripting (XSS) attacks, always set this attribute to "Yes". If you need to render HTML tags in the message, set this attribute to "No".</p>',
'<p><b>Note:</b> You can still escape only certain page items, by using the &PAGE_ITEM!HTML. substitution string format.</p>'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851203403342114997)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_static_id=>'attribute_06'
,p_prompt=>'Display Location'
,p_apexlang_name=>'displayLocation'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'inline:page'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'show-error'
,p_lov_type=>'STATIC'
,p_help_text=>'<p>Select where the error message is displayed. Error messages can be displayed inline underneath an Associated Item label and/or in a Notification area, defined as part of the page template.</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851204773115114996)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851203403342114997)
,p_display_sequence=>30
,p_display_value=>'Inline in Notification'
,p_return_value=>'page'
,p_apexlang_name=>'inlineInNotification'
,p_help_text=>'<p>In a notification</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851204334735114997)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851203403342114997)
,p_display_sequence=>20
,p_display_value=>'Inline with Field'
,p_return_value=>'inline'
,p_apexlang_name=>'inlineWithField'
,p_help_text=>'<p>Inline with a specific Page Item</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851203806731114997)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851203403342114997)
,p_display_sequence=>10
,p_display_value=>'Inline with Field and in Notification'
,p_return_value=>'inline:page'
,p_apexlang_name=>'inlineWithFieldAndInNotification'
,p_help_text=>'<p>Both inline with a specific Page Item and in a notification</p>'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851205264042114996)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_static_id=>'attribute_07'
,p_prompt=>'Associated Item(s)'
,p_apexlang_name=>'associatedItemS'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851203403342114997)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'inline,inline:page'
,p_help_text=>'<p>Displays the error notification inline with a page item. You can select multiple page items to associate the same message with them.</p>'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851205730772114996)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_static_id=>'attribute_08'
,p_prompt=>'Autodismiss'
,p_apexlang_name=>'autodismiss'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'show-page-success,show-error'
,p_help_text=>'<p>By default, success notifications are displayed until the user closes them. Set this attribute to "Yes" to auto dismiss the notification after a specific amount of time.</p>'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851206058846114996)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_static_id=>'attribute_09'
,p_prompt=>'Autodismiss After'
,p_apexlang_name=>'autodismissAfter'
,p_attribute_type=>'NUMBER'
,p_is_required=>true
,p_default_value=>'10'
,p_unit=>'seconds'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851205730772114996)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'<p>The time in seconds until the notification will be dismissed.</p>'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851206536939114996)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_static_id=>'attribute_10'
,p_prompt=>'Clear Other Errors'
,p_apexlang_name=>'clearOtherErrors'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'show-error'
,p_help_text=>'<p>Enable this option to clear any existing errors before showing your new error message.</p>'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851206874776114996)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_static_id=>'attribute_11'
,p_prompt=>'Page Item(s)'
,p_apexlang_name=>'pageItemS'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'clear-errors'
,p_help_text=>'<p>Enter a list of page item(s) that you would like to clear errors for. Leave this attribute blank if you want to clear all errors.</p>'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851207253582114995)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_static_id=>'attribute_12'
,p_prompt=>'Messages Type'
,p_apexlang_name=>'messagesType'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>true
,p_default_value=>'success,error'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'clear-message'
,p_lov_type=>'STATIC'
,p_help_text=>'<p>Select which type of messages should be dismissed automatically.</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851208236401114995)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851207253582114995)
,p_display_sequence=>20
,p_display_value=>'Error'
,p_return_value=>'error'
,p_apexlang_name=>'error'
,p_help_text=>'<p>Error messages will be automatically removed.</p>'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44851207677932114995)
,p_plugin_attribute_id=>wwv_flow_imp.id(44851207253582114995)
,p_display_sequence=>10
,p_display_value=>'Success'
,p_return_value=>'success'
,p_apexlang_name=>'success'
,p_help_text=>'<p>Success messages will be automatically removed.</p>'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44851208682772114995)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>130
,p_static_id=>'attribute_13'
,p_prompt=>'Autodismiss After'
,p_apexlang_name=>'autodismissAfter2'
,p_attribute_type=>'INTEGER'
,p_is_required=>true
,p_default_value=>'5'
,p_unit=>'seconds'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44851197359398114999)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'clear-message'
,p_help_text=>'<p>Enter the number of seconds to auto dismiss all APEX Notifications.</p>'
);
wwv_flow_imp_shared.create_plugin_std_attribute(
 p_id=>wwv_flow_imp.id(44851221108038114989)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'function(config){',
'    config.message = ''New Message'';',
'}',
'</pre>'))
,p_help_text=>'Javascript initialization function which allows you to override any settings right before the dynamic action is invoked.'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A20676C6F62616C732061706578202A2F0A0A766172207563203D2077696E646F772E7563207C7C207B7D3B0A75632E6D657373616765203D2075632E6D657373616765207C7C207B7D3B0A0A2F2A2A0A202A20546869732066756E6374696F6E2069';
wwv_flow_imp.g_varchar2_table(2) := '732073686F77696E67206F7220686964696E672074686520676976656E2073756363657373206F72206572726F72206D6573736167652E0A202A0A202A2040706172616D207B6F626A6563747D2020206461436F6E746578742020202020202020202020';
wwv_flow_imp.g_varchar2_table(3) := '202020202020202020202044796E616D696320416374696F6E20636F6E746578742061732070617373656420696E20627920415045580A202A2040706172616D207B6F626A6563747D202020636F6E666967202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(4) := '20202020202020436F6E66696775726174696F6E206F626A65637420686F6C64696E6720746865206D65737361676520636F6E66696775726174696F6E0A202A2040706172616D207B737472696E677D202020636F6E6669672E6D657373616765202020';
wwv_flow_imp.g_varchar2_table(5) := '2020202020202020202020202020537472696E67206F72204A532066756E6374696F6E2072657475726E696E6720746865206D65737361676520746578740A202A2040706172616D207B737472696E677D202020636F6E6669672E616374696F6E547970';
wwv_flow_imp.g_varchar2_table(6) := '6520202020202020202020202020204F6E65206F663A2073686F7750616765537563636573737C6869646550616765537563636573737C73686F774572726F727C636C6561724572726F72737C636C6561724572726F720A202A2040706172616D207B62';
wwv_flow_imp.g_varchar2_table(7) := '6F6F6C65616E7D20205B636F6E6669672E6573636170655D202020202020202020202020202020205768657468657220746F2065736361706520746865206D65737361676520746578740A202A2040706172616D207B6E756D6265727D2020205B636F6E';
wwv_flow_imp.g_varchar2_table(8) := '6669672E636F6E6669672E6475726174696F6E5D20202020202020416D6F756E74206F66206D696C6C697365636F6E647320616674657220746861742074686520706167652073756363657373206D6573736167652073686F756C64206175746F6D6174';
wwv_flow_imp.g_varchar2_table(9) := '6963616C6C79206265206469736D69737365640A202A2040706172616D207B737472696E677D2020205B636F6E6669672E6C6F636174696F6E5D2020202020202020202020202020576865726520746F20646973706C617920746865206572726F72206D';
wwv_flow_imp.g_varchar2_table(10) := '6573736167652C206F6E20706167652C20696E6C696E652C20626F74680A202A2040706172616D207B737472696E677D2020205B636F6E6669672E706167654974656D5D20202020202020202020202020204E616D65206F662074686520706167652069';
wwv_flow_imp.g_varchar2_table(11) := '74656D20776869636820746865206572726F72206D6573736167652073686F756C64206265206173736F63696174656420776974680A202A2040706172616D207B737472696E677D2020205B636F6E6669672E706167654974656D735D20202020202020';
wwv_flow_imp.g_varchar2_table(12) := '2020202020204E616D65206F66207468652070616765206974656D7320776869636820746865206572726F72206D6573736167652073686F756C6420626520636C656172656420666F720A202A2040706172616D207B626F6F6C65616E7D2020636F6E66';
wwv_flow_imp.g_varchar2_table(13) := '69672E636C656172537563636573732020202020202020202020205768657468657220746F206175746F2D636C6561722073756363657373206D657373616765730A202A2040706172616D207B626F6F6C65616E7D2020636F6E6669672E636C65617245';
wwv_flow_imp.g_varchar2_table(14) := '72726F7220202020202020202020202020205768657468657220746F206175746F2D636C656172206572726F72206D657373616765730A202A2040706172616D207B66756E6374696F6E7D205B696E6974466E5D20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(15) := '202020202020204A61766173637269707420496E697469616C697A6174696F6E20436F64652046756E6374696F6E2C2069742063616E20626520756E646566696E65640A2A2F0A75632E6D6573736167652E616374696F6E203D2066756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(16) := '286461436F6E746578742C20636F6E6669672C20696E6974466E29207B0A0A2020202076617220706C7567696E4E616D65203D20275543202D204D65737361676520416374696F6E73273B0A20202020617065782E64656275672E696E666F28706C7567';
wwv_flow_imp.g_varchar2_table(17) := '696E4E616D652C20636F6E666967293B0A0A202020202F2F20416C6C6F772074686520646576656C6F70657220746F20706572666F726D20616E79206C617374202863656E7472616C697A656429206368616E676573207573696E67204A617661736372';
wwv_flow_imp.g_varchar2_table(18) := '69707420496E697469616C697A6174696F6E20436F64652073657474696E670A2020202069662028696E6974466E20696E7374616E63656F662046756E6374696F6E29207B0A2020202020202020696E6974466E2E63616C6C286461436F6E746578742C';
wwv_flow_imp.g_varchar2_table(19) := '20636F6E666967293B0A202020207D0A0A20202020766172206D6573736167653B0A0A202020202F2F205265706C6163696E6720737562737469747574696E6720737472696E677320616E64206573636170696E6720746865206D6573736167650A2020';
wwv_flow_imp.g_varchar2_table(20) := '2020696620285B2773686F775061676553756363657373272C202773686F774572726F72275D2E696E6465784F6628636F6E6669672E616374696F6E5479706529203E202D3129207B0A0A202020202020202069662028636F6E6669672E6D6573736167';
wwv_flow_imp.g_varchar2_table(21) := '6520696E7374616E63656F662046756E6374696F6E29207B0A2020202020202020202020206D657373616765203D20636F6E6669672E6D6573736167652E63616C6C286461436F6E74657874293B0A20202020202020207D20656C7365207B0A20202020';
wwv_flow_imp.g_varchar2_table(22) := '20202020202020206D657373616765203D20636F6E6669672E6D6573736167653B0A20202020202020207D0A0A20202020202020202F2F20205265706C6163696E6720737562737469747574696F6E20737472696E67730A20202020202020202F2F2020';
wwv_flow_imp.g_varchar2_table(23) := '576520646F6E27742065736361706520746865206D6573736167652062792064656661756C742E205765206C65742074686520646576656C6F70657220646563696465207768657468657220746F206573636170650A20202020202020202F2F20207468';
wwv_flow_imp.g_varchar2_table(24) := '652077686F6C65206D6573736167652C206F72206A75737420696E76696475616C2070616765206974656D73207669612024504147455F4954454D2148544D4C2E0A2020202020202020696620286D65737361676529207B0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(25) := '206D657373616765203D20617065782E7574696C2E6170706C7954656D706C617465286D6573736167652C207B0A2020202020202020202020202020202064656661756C7445736361706546696C7465723A206E756C6C0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(26) := '7D293B0A20202020202020207D20656C7365207B0A2020202020202020202020202F2F20496E206361736520746865206D65737361676520697320656D7074792C2077652077696C6C2065786974206E6F77206173207468657265206973206E6F746869';
wwv_flow_imp.g_varchar2_table(27) := '6E6720746F2073686F770A2020202020202020202020202F2F2077652077696C6C206C6F672061206465627567206D65737361676520746F20696E64696361746520746865206D65737361676520697320626C616E6B2E2054686973206973207468650A';
wwv_flow_imp.g_varchar2_table(28) := '2020202020202020202020202F2F2073616D65206265686176696F7572206173206F7572204E6F74696669636174696F6E7320706C75672D696E0A202020202020202020202020617065782E64656275672E6C6F6728636F6E6669672E706C7567696E4E';
wwv_flow_imp.g_varchar2_table(29) := '616D65202B20273A20746865206D65737361676520697320656D7074792C20736F206974206973206E6F742073686F776E2127293B0A20202020202020202020202072657475726E3B0A20202020202020207D0A0A20202020202020202F2F2045736361';
wwv_flow_imp.g_varchar2_table(30) := '7065205370656369616C2043686172616374657273206174747269627574650A202020202020202069662028636F6E6669672E65736361706529207B0A2020202020202020202020206D657373616765203D20617065782E7574696C2E65736361706548';
wwv_flow_imp.g_varchar2_table(31) := '544D4C286D657373616765293B0A20202020202020207D0A202020207D0A0A202020207377697463682028636F6E6669672E616374696F6E5479706529207B0A202020202020202063617365202773686F775061676553756363657373273A0A20202020';
wwv_flow_imp.g_varchar2_table(32) := '202020202020202075632E6D6573736167652E73686F775061676553756363657373286D6573736167652C20636F6E6669672E636F6E666967293B0A202020202020202020202020627265616B3B0A202020202020202063617365202768696465506167';
wwv_flow_imp.g_varchar2_table(33) := '6553756363657373273A0A20202020202020202020202075632E6D6573736167652E68696465506167655375636365737328293B0A202020202020202020202020627265616B3B0A202020202020202063617365202773686F774572726F72273A0A2020';
wwv_flow_imp.g_varchar2_table(34) := '2020202020202020202075632E6D6573736167652E73686F774572726F72286D6573736167652C20636F6E6669672E636F6E666967293B0A202020202020202020202020627265616B3B0A2020202020202020636173652027636C6561724572726F7273';
wwv_flow_imp.g_varchar2_table(35) := '273A0A20202020202020202020202075632E6D6573736167652E636C6561724572726F727328636F6E6669672E706167654974656D73293B0A202020202020202020202020627265616B3B0A2020202020202020636173652027636C6561724D65737361';
wwv_flow_imp.g_varchar2_table(36) := '6765273A0A20202020202020202020202075632E6D6573736167652E636C6561724D65737361676528636F6E6669672E636C656172537563636573732C20636F6E6669672E636C6561724572726F722C20636F6E6669672E686964654166746572293B0A';
wwv_flow_imp.g_varchar2_table(37) := '202020202020202020202020627265616B3B0A202020207D0A7D3B0A0A75632E6D6573736167652E73686F775061676553756363657373203D2066756E6374696F6E20286D6573736167652C20636F6E66696729207B0A0A202020202F2F2073746F7020';
wwv_flow_imp.g_varchar2_table(38) := '616E79206C696E676572696E67206175746F206469736D697373657320696620616E206578697374696E67206D6573736167652068617320616C7265616479206265656E2073686F776E0A202020207661722063757272656E7454696D656F7574496420';
wwv_flow_imp.g_varchar2_table(39) := '3D2075632E6D6573736167652E73686F7750616765537563636573732E74696D656F757449643B0A202020206966202863757272656E7454696D656F7574496429207B0A2020202020202020636C656172496E74657276616C2863757272656E7454696D';
wwv_flow_imp.g_varchar2_table(40) := '656F75744964293B0A202020202020202064656C6574652075632E6D6573736167652E73686F7750616765537563636573732E74696D656F757449643B0A202020207D0A0A202020202F2F20616E79206573636170696E6720697320617373756D656420';
wwv_flow_imp.g_varchar2_table(41) := '746F2068617665206265656E20646F6E65206279206E6F770A20202020617065782E6D6573736167652E73686F775061676553756363657373286D657373616765293B0A0A202020202F2F207365747570206F75722074696D657220746F206175746F20';
wwv_flow_imp.g_varchar2_table(42) := '6469736D69737320746865206D6573736167652061667465722058207365636F6E64730A2020202069662028636F6E6669672E6475726174696F6E29207B0A202020202020202075632E6D6573736167652E73686F7750616765537563636573732E7469';
wwv_flow_imp.g_varchar2_table(43) := '6D656F75744964203D2073657454696D656F75742866756E6374696F6E202829207B0A20202020202020202020202075632E6D6573736167652E68696465506167655375636365737328293B0A20202020202020207D2C20636F6E6669672E6475726174';
wwv_flow_imp.g_varchar2_table(44) := '696F6E293B0A202020207D0A7D3B0A0A75632E6D6573736167652E686964655061676553756363657373203D2066756E6374696F6E202829207B0A20202020617065782E6D6573736167652E68696465506167655375636365737328293B0A7D3B0A0A75';
wwv_flow_imp.g_varchar2_table(45) := '632E6D6573736167652E73686F774572726F72203D2066756E6374696F6E20286D6573736167652C20636F6E66696729207B0A0A202020202F2F2073746F7020616E79206C696E676572696E67206175746F206469736D697373657320696620616E2065';
wwv_flow_imp.g_varchar2_table(46) := '78697374696E67206D6573736167652068617320616C7265616479206265656E2073686F776E0A202020207661722063757272656E7454696D656F75744964203D2075632E6D6573736167652E73686F774572726F722E74696D656F757449643B0A2020';
wwv_flow_imp.g_varchar2_table(47) := '20206966202863757272656E7454696D656F7574496429207B0A2020202020202020636C656172496E74657276616C2863757272656E7454696D656F75744964293B0A202020202020202064656C6574652075632E6D6573736167652E73686F77457272';
wwv_flow_imp.g_varchar2_table(48) := '6F722E74696D656F757449643B0A202020207D0A0A202020202F2F206F7074696F6E616C6C7920636C656172206578697374696E67206572726F7273206265666F72652073686F77696E6720746865206E6577206F6E650A2020202069662028636F6E66';
wwv_flow_imp.g_varchar2_table(49) := '69672E636C6561724572726F7273292075632E6D6573736167652E636C6561724572726F727328293B0A0A202020202F2F206966207765206173736F636961746520746865206D657373616765207769746820616E206974656D207468656E207765206D';
wwv_flow_imp.g_varchar2_table(50) := '6179206861766520646566696E6564206D756C7469706C652070616765206974656D730A2020202069662028636F6E6669672E706167654974656D20262620636F6E6669672E6C6F636174696F6E2E696E636C756465732827696E6C696E65272929207B';
wwv_flow_imp.g_varchar2_table(51) := '0A20202020202020202F2F2053686F77206F75722070616765206974656D206572726F72730A2020202020202020636F6E6669672E706167654974656D2E73706C697428272C27292E666F72456163682866756E6374696F6E2028706167654974656D29';
wwv_flow_imp.g_varchar2_table(52) := '207B0A2020202020202020202020202F2F2053686F77206F75722041504558206572726F72206D6573736167650A202020202020202020202020617065782E6D6573736167652E73686F774572726F7273287B0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(53) := '747970653A20276572726F72272C0A202020202020202020202020202020206C6F636174696F6E3A205B27696E6C696E65275D2C0A20202020202020202020202020202020706167654974656D3A20706167654974656D2C0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(54) := '20202020206D6573736167653A206D6573736167652C0A202020202020202020202020202020202F2F616E79206573636170696E6720697320617373756D656420746F2068617665206265656E20646F6E65206279206E6F770A20202020202020202020';
wwv_flow_imp.g_varchar2_table(55) := '202020202020756E736166653A2066616C73650A2020202020202020202020207D293B0A20202020202020207D293B0A20202020202020202F2F2073686F77206172652070616765206C6576656C206572726F7220696620646566696E65640A20202020';
wwv_flow_imp.g_varchar2_table(56) := '2020202069662028636F6E6669672E6C6F636174696F6E2E696E636C75646573282770616765272929207B0A202020202020202020202020617065782E6D6573736167652E73686F774572726F7273287B0A202020202020202020202020202020207479';
wwv_flow_imp.g_varchar2_table(57) := '70653A20276572726F72272C0A202020202020202020202020202020206C6F636174696F6E3A205B2770616765275D2C0A20202020202020202020202020202020706167654974656D3A20756E646566696E65642C0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(58) := '20206D6573736167653A206D6573736167652C0A202020202020202020202020202020202F2F616E79206573636170696E6720697320617373756D656420746F2068617665206265656E20646F6E65206279206E6F770A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(59) := '202020756E736166653A2066616C73650A2020202020202020202020207D293B0A20202020202020207D0A202020207D20656C7365207B0A20202020202020202F2F2053686F77206F7572206572726F72206D6573736167650A20202020202020206170';
wwv_flow_imp.g_varchar2_table(60) := '65782E6D6573736167652E73686F774572726F7273287B0A202020202020202020202020747970653A20276572726F72272C0A2020202020202020202020206C6F636174696F6E3A20636F6E6669672E6C6F636174696F6E2C0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(61) := '2020706167654974656D3A20636F6E6669672E706167654974656D2C0A2020202020202020202020206D6573736167653A206D6573736167652C0A2020202020202020202020202F2F616E79206573636170696E6720697320617373756D656420746F20';
wwv_flow_imp.g_varchar2_table(62) := '68617665206265656E20646F6E65206279206E6F770A202020202020202020202020756E736166653A2066616C73650A20202020202020207D293B0A202020207D0A0A202020202F2F207365747570206F75722074696D657220746F206175746F206469';
wwv_flow_imp.g_varchar2_table(63) := '736D69737320746865206D6573736167652061667465722058207365636F6E64730A2020202069662028636F6E6669672E6475726174696F6E29207B0A202020202020202075632E6D6573736167652E73686F774572726F722E74696D656F7574496420';
wwv_flow_imp.g_varchar2_table(64) := '3D2073657454696D656F75742866756E6374696F6E202829207B0A20202020202020202020202075632E6D6573736167652E636C6561724572726F727328293B0A20202020202020207D2C20636F6E6669672E6475726174696F6E293B0A202020207D0A';
wwv_flow_imp.g_varchar2_table(65) := '7D3B0A0A75632E6D6573736167652E636C6561724572726F7273203D2066756E6374696F6E2028706167654974656D7329207B0A202020202F2F20636865636B2069662077652061726520636C656172696E672031206F72206D6F726520706167652069';
wwv_flow_imp.g_varchar2_table(66) := '74656D73206966206E6F74207765207468656E20636C6561722065766572797468696E670A202020206966202841727261792E6973417272617928706167654974656D732920262620706167654974656D732E6C656E677468203E203029207B0A202020';
wwv_flow_imp.g_varchar2_table(67) := '2020202020706167654974656D732E666F72456163682866756E6374696F6E20286974656D2C20696E64657829207B0A202020202020202020202020696620286974656D2920617065782E6D6573736167652E636C6561724572726F7273286974656D2E';
wwv_flow_imp.g_varchar2_table(68) := '7472696D2829293B0A20202020202020207D290A202020207D20656C7365207B0A2020202020202020617065782E6D6573736167652E636C6561724572726F727328293B0A202020207D0A7D3B0A0A75632E6D6573736167652E636C6561724D65737361';
wwv_flow_imp.g_varchar2_table(69) := '6765203D2066756E6374696F6E2028636C656172537563636573732C20636C6561724572726F722C2068696465416674657229207B0A20202020636F6E737420535543434553535F53454C4543544F52203D2027415045585F535543434553535F4D4553';
wwv_flow_imp.g_varchar2_table(70) := '53414745273B0A20202020636F6E7374204552524F525F53454C4543544F52203D2027415045585F4552524F525F4D455353414745273B0A0A20202020636F6E73742073756363657373456C203D20646F63756D656E742E676574456C656D656E744279';
wwv_flow_imp.g_varchar2_table(71) := '496428535543434553535F53454C4543544F52293B0A20202020636F6E7374206572726F72456C203D20646F63756D656E742E676574456C656D656E7442794964284552524F525F53454C4543544F52293B0A0A20202020636F6E73742056495349424C';
wwv_flow_imp.g_varchar2_table(72) := '455F434C53203D2027752D76697369626C65273B0A20202020636F6E73742048494444454E5F434C53203D2027752D68696464656E273B0A0A20202020617065782E6D6573736167652E7365745468656D65486F6F6B73287B0A20202020202020206265';
wwv_flow_imp.g_varchar2_table(73) := '666F726553686F773A2066756E6374696F6E20286D7367547970652C206D7367456C29207B0A202020202020202020202020636F6E736F6C652E6C6F67286D7367456C293B0A2020202020202020202020206966202828636C6561725375636365737320';
wwv_flow_imp.g_varchar2_table(74) := '2626206D736754797065203D3D2027737563636573732729207C7C2028636C6561724572726F72202626206D736754797065203D3D3D20276572726F72272929207B0A2020202020202020202020202020202073657454696D656F75742866756E637469';
wwv_flow_imp.g_varchar2_table(75) := '6F6E202829207B0A20202020202020202020202020202020202020206D7367456C2E72656D6F7665436C6173732856495349424C455F434C53292E616464436C6173732848494444454E5F434C53293B0A202020202020202020202020202020207D2C20';
wwv_flow_imp.g_varchar2_table(76) := '686964654166746572293B0A2020202020202020202020207D0A20202020202020207D0A202020207D290A0A202020202F2F20636F6E7374206F62736572766572436F6E666967203D207B0A202020202F2F2020202020617474726962757465733A2074';
wwv_flow_imp.g_varchar2_table(77) := '7275652C0A202020202F2F202020202061747472696275746546696C7465723A205B27636C617373275D2C0A202020202F2F20202020206368696C644C6973743A20747275652C0A202020202F2F2020202020737562747265653A2066616C73650A2020';
wwv_flow_imp.g_varchar2_table(78) := '20202F2F207D3B0A0A202020202F2F20636F6E73742063616C6C6261636B203D2066756E6374696F6E286D75746174696F6E734C6973742C206F62736572766572297B0A202020202F2F2020202020636F6E736F6C652E6C6F6728276D75746174696F6E';
wwv_flow_imp.g_varchar2_table(79) := '4C697374272C206D75746174696F6E734C697374293B0A202020202F2F2020202020666F7228636F6E7374206D75746174696F6E206F66206D75746174696F6E734C697374297B0A202020202F2F2020202020202020206966286D75746174696F6E2E74';
wwv_flow_imp.g_varchar2_table(80) := '797065203D3D3D20276368696C644C69737427297B0A202020202F2F202020202020202020202020206966286D75746174696F6E2E61646465644E6F6465732E6C656E677468203E2030297B0A202020202F2F2020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(81) := '636F6E736F6C652E6C6F67282741204E6F646520686173206265656E206164646564272C206D75746174696F6E2E61646465644E6F6465735B305D293B0A202020202F2F2020202020202020202020202020202020636F6E736F6C652E6C6F67286D7574';
wwv_flow_imp.g_varchar2_table(82) := '6174696F6E293B0A202020202F2F202020202020202020202020207D0A0A202020202F2F202020202020202020202020206966286D75746174696F6E2E72656D6F7665644E6F6465732E6C656E677468203E2030297B0A202020202F2F20202020202020';
wwv_flow_imp.g_varchar2_table(83) := '20202020202020202020636F6E736F6C652E6C6F67282741204E6F646520686173206265656E2072656D6F766564272C206D75746174696F6E2E72656D6F7665644E6F6465735B305D293B0A202020202F2F202020202020202020202020202020202063';
wwv_flow_imp.g_varchar2_table(84) := '6F6E736F6C652E6C6F67286D75746174696F6E293B0A202020202F2F202020202020202020202020207D0A202020202F2F2020202020202020207D0A202020202F2F20202020207D0A202020202F2F207D0A0A202020202F2F20636F6E7374206F627365';
wwv_flow_imp.g_varchar2_table(85) := '72766572203D206E6577204D75746174696F6E4F627365727665722863616C6C6261636B293B0A0A202020202F2F20696628636C656172537563636573732026262073756363657373456C297B0A202020202F2F20202020206F627365727665722E6F62';
wwv_flow_imp.g_varchar2_table(86) := '73657276652873756363657373456C2C6F62736572766572436F6E666967293B0A202020202F2F207D0A0A202020202F2F20696628636C6561724572726F72202626206572726F72456C297B0A202020202F2F20202020206F627365727665722E6F6273';
wwv_flow_imp.g_varchar2_table(87) := '65727665286572726F72456C2C6F62736572766572436F6E666967293B0A202020202F2F207D0A0A7D0A0A0A0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(44852390446949868132)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_file_name=>'js/script.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '7661722075633D77696E646F772E75637C7C7B7D3B75632E6D6573736167653D75632E6D6573736167657C7C7B7D2C75632E6D6573736167652E616374696F6E3D66756E6374696F6E28652C732C61297B76617220633B696628617065782E6465627567';
wwv_flow_imp.g_varchar2_table(2) := '2E696E666F28225543202D204D65737361676520416374696F6E73222C73292C6120696E7374616E63656F662046756E6374696F6E2626612E63616C6C28652C73292C5B2273686F775061676553756363657373222C2273686F774572726F72225D2E69';
wwv_flow_imp.g_varchar2_table(3) := '6E6465784F6628732E616374696F6E54797065293E2D31297B6966282128633D732E6D65737361676520696E7374616E63656F662046756E6374696F6E3F732E6D6573736167652E63616C6C2865293A732E6D657373616765292972657475726E20766F';
wwv_flow_imp.g_varchar2_table(4) := '696420617065782E64656275672E6C6F6728732E706C7567696E4E616D652B223A20746865206D65737361676520697320656D7074792C20736F206974206973206E6F742073686F776E2122293B633D617065782E7574696C2E6170706C7954656D706C';
wwv_flow_imp.g_varchar2_table(5) := '61746528632C7B64656661756C7445736361706546696C7465723A6E756C6C7D292C732E657363617065262628633D617065782E7574696C2E65736361706548544D4C286329297D73776974636828732E616374696F6E54797065297B63617365227368';
wwv_flow_imp.g_varchar2_table(6) := '6F775061676553756363657373223A75632E6D6573736167652E73686F77506167655375636365737328632C732E636F6E666967293B627265616B3B6361736522686964655061676553756363657373223A75632E6D6573736167652E68696465506167';
wwv_flow_imp.g_varchar2_table(7) := '655375636365737328293B627265616B3B636173652273686F774572726F72223A75632E6D6573736167652E73686F774572726F7228632C732E636F6E666967293B627265616B3B6361736522636C6561724572726F7273223A75632E6D657373616765';
wwv_flow_imp.g_varchar2_table(8) := '2E636C6561724572726F727328732E706167654974656D73293B627265616B3B6361736522636C6561724D657373616765223A75632E6D6573736167652E636C6561724D65737361676528732E636C656172537563636573732C732E636C656172457272';
wwv_flow_imp.g_varchar2_table(9) := '6F722C732E686964654166746572297D7D2C75632E6D6573736167652E73686F7750616765537563636573733D66756E6374696F6E28652C73297B76617220613D75632E6D6573736167652E73686F7750616765537563636573732E74696D656F757449';
wwv_flow_imp.g_varchar2_table(10) := '643B61262628636C656172496E74657276616C2861292C64656C6574652075632E6D6573736167652E73686F7750616765537563636573732E74696D656F75744964292C617065782E6D6573736167652E73686F7750616765537563636573732865292C';
wwv_flow_imp.g_varchar2_table(11) := '732E6475726174696F6E26262875632E6D6573736167652E73686F7750616765537563636573732E74696D656F757449643D73657454696D656F75742866756E6374696F6E28297B75632E6D6573736167652E6869646550616765537563636573732829';
wwv_flow_imp.g_varchar2_table(12) := '7D2C732E6475726174696F6E29297D2C75632E6D6573736167652E6869646550616765537563636573733D66756E6374696F6E28297B617065782E6D6573736167652E68696465506167655375636365737328297D2C75632E6D6573736167652E73686F';
wwv_flow_imp.g_varchar2_table(13) := '774572726F723D66756E6374696F6E28652C73297B76617220613D75632E6D6573736167652E73686F774572726F722E74696D656F757449643B61262628636C656172496E74657276616C2861292C64656C6574652075632E6D6573736167652E73686F';
wwv_flow_imp.g_varchar2_table(14) := '774572726F722E74696D656F75744964292C732E636C6561724572726F7273262675632E6D6573736167652E636C6561724572726F727328292C732E706167654974656D2626732E6C6F636174696F6E2E696E636C756465732822696E6C696E6522293F';
wwv_flow_imp.g_varchar2_table(15) := '28732E706167654974656D2E73706C697428222C22292E666F72456163682866756E6374696F6E2873297B617065782E6D6573736167652E73686F774572726F7273287B747970653A226572726F72222C6C6F636174696F6E3A5B22696E6C696E65225D';
wwv_flow_imp.g_varchar2_table(16) := '2C706167654974656D3A732C6D6573736167653A652C756E736166653A21317D297D292C732E6C6F636174696F6E2E696E636C7564657328227061676522292626617065782E6D6573736167652E73686F774572726F7273287B747970653A226572726F';
wwv_flow_imp.g_varchar2_table(17) := '72222C6C6F636174696F6E3A5B2270616765225D2C706167654974656D3A766F696420302C6D6573736167653A652C756E736166653A21317D29293A617065782E6D6573736167652E73686F774572726F7273287B747970653A226572726F72222C6C6F';
wwv_flow_imp.g_varchar2_table(18) := '636174696F6E3A732E6C6F636174696F6E2C706167654974656D3A732E706167654974656D2C6D6573736167653A652C756E736166653A21317D292C732E6475726174696F6E26262875632E6D6573736167652E73686F774572726F722E74696D656F75';
wwv_flow_imp.g_varchar2_table(19) := '7449643D73657454696D656F75742866756E6374696F6E28297B75632E6D6573736167652E636C6561724572726F727328297D2C732E6475726174696F6E29297D2C75632E6D6573736167652E636C6561724572726F72733D66756E6374696F6E286529';
wwv_flow_imp.g_varchar2_table(20) := '7B41727261792E697341727261792865292626652E6C656E6774683E303F652E666F72456163682866756E6374696F6E28652C73297B652626617065782E6D6573736167652E636C6561724572726F727328652E7472696D2829297D293A617065782E6D';
wwv_flow_imp.g_varchar2_table(21) := '6573736167652E636C6561724572726F727328297D2C75632E6D6573736167652E636C6561724D6573736167653D66756E6374696F6E28652C732C61297B646F63756D656E742E676574456C656D656E74427949642822415045585F535543434553535F';
wwv_flow_imp.g_varchar2_table(22) := '4D45535341474522292C646F63756D656E742E676574456C656D656E74427949642822415045585F4552524F525F4D45535341474522293B617065782E6D6573736167652E7365745468656D65486F6F6B73287B6265666F726553686F773A66756E6374';
wwv_flow_imp.g_varchar2_table(23) := '696F6E28632C72297B636F6E736F6C652E6C6F672872292C286526262273756363657373223D3D637C7C732626226572726F72223D3D3D6329262673657454696D656F75742866756E6374696F6E28297B722E72656D6F7665436C6173732822752D7669';
wwv_flow_imp.g_varchar2_table(24) := '7369626C6522292E616464436C6173732822752D68696464656E22297D2C61297D7D297D3B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(44852390820021868128)
,p_plugin_id=>wwv_flow_imp.id(44851197089831115000)
,p_file_name=>'js/script.min.js'
,p_mime_type=>'text/javascript'
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
