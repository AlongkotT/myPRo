*** Settings ***
Documentation     Check Login Status
Library         Collections
Library         String 
Library         REST
Library         BuiltIn
Library         RequestsLibrary
Library         HttpLibrary.HTTP
Library         Encrypt-Decrypt.py
Library         DebugLibrary
Library         mystr.py

*** Test Cases ***
Incorrect phone number    
    ${out}              User Login                  {"cmd":"00005","param":["1111111440","222222"]}       
    ${result}           GetResult                   ${out}
    Should Contain      ${result}                   False

Correct phone number    
    ${out}              User Login                  {"cmd":"00005","param":["1111111440","555555"]}
    ${result}           GetResult                   ${out}
    Should Contain      ${result}                   True

Blank phone number    
    ${out}              User Login                  {"cmd":"00005","param":["","222222"]}
    ${result}           GetResult                   ${out}
    Should Contain      ${result}                   False

Blank password    
    ${out}              User Login                  {"cmd":"00005","param":["1111111440",""]}
    ${result}           GetResult                   ${out}
    Should Contain      ${result}                   False

   
*** Keywords ***
User Login
    [Arguments]  ${ndata}
    ${token}            GetTokenFirst   
    ${header}           SetHeader                   ${token} 
    Set Headers         ${header}   
    ${data}=            Create Dictionary           param=${ndata}
    REST.Post           http://localhost/LumpsumWS/Service.asmx/GetCmdValue    ${data}
    ${out}              Output                  response body    string
    ${out}              ConvertData             ${out}   
    ${json}             evaluate                json.loads('''${out}''')    json
    ${data}             Convert To String       ${json['d']}       
    [return]   ${data}

GetTokenFirst    
    ${header}           GetHeader
    Set Headers         ${header}
    REST.Post           http://localhost/LumpsumWS/Service.asmx/StartUpApplication   
    ${out}              Output                  response body    string
    log                 return data is ${out}       
    ${out}              ConvertData             ${out}
    ${json}             evaluate                json.loads('''${out}''')    json    
    ${json_string}      evaluate                json.dumps(${json})                 json
    # log to console      \nNew JSON string:\n${json_string}
    ${token}            Convert To String       ${json['d']['token']}
    [return]            ${token}

GetHeaders
    [Arguments]  ${tokens}
    ${headers}    Create Dictionary    
    ...    lumpsum_unique_id   0bc8083eaecfb6f7
    ...    lumpsum_token_id    ${tokens}
    ...    app_version         1.0
    ...    device              Samsung SM
    ...    os_version          Android
    ...    os_type             android
    ...    lumpsum_email       wasabiTitleTp@gmail.com
    ...    lang                th

    [return]   ${headers}

GetHeader
   
    ${headerss}    Create Dictionary    
    ...    lumpsum_unique_id   0bc8083eaecfb6f7
    ...    lumpsum_token_id    1234
    ...    app_version         1.0
    ...    device              Samsung SM
    ...    os_version          Android
    ...    os_type             android
    ...    lumpsum_email       wasabiTitleTp@gmail.com
    ...    lang                th


    [return]   ${headerss}

SetHeader
    [Arguments]    ${token}
    ${header}  GetHeaders   ${token}
    [Return]   ${header}

ConvertData
    [Arguments]     ${str}
    ${str}              Convert To String       ${str} 
    # log to console      \ncon string:\n${str}
    ${str}              Replace String          ${str}      u'      "
    ${str}              Replace String          ${str}      "{      {
    ${str}              Replace String          ${str}      }'}     }}
    ${out}              Replace String          ${str}      '       "
    ${out}              Replace String          ${out}      False,       "False",
    ${out}              Replace String          ${out}      True,        "True",
    # log to console      \nre string:\n${out}       
    [Return]  ${out}

GetResult
    [Arguments]  ${datain}
    ${datain}               convertoStr                 ${datain}
    ${datain}               ConvertData                 ${datain}    
    ${json}                 evaluate                    json.loads('''${datain}''')    json    
    ${result}               Convert To String           ${json['data']['result']}
    [return]   ${result}