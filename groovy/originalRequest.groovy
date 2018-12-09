def data = """{"msgtype": "markdown", 
    "markdown": {
        "title": "【E2E ${BUILD_STATUS}】 UAT - MARS - Build # ${BUILD_NUMBER} -  ${CAUSE_NOTE}",
        "text": "### 【E2E ${BUILD_STATUS}】 UAT - MARS - Build # ${BUILD_NUMBER} -  ${CAUSE_NOTE}\n- [e2e录像在线播放](http://xxxxxxxxx)\n- [console log](${BUILD_URL}console)"
     }
 }"""

def con = "https://oapi.dingtalk.com/robot/send?access_token=xxxxxxxx".toURL().openConnection();
con.setDoOutput(true);
con.setDoInput(true);
con.setRequestProperty("Content-Type", "application/json");
con.outputStream.withWriter { writer ->
  writer << data
}
String response = con.inputStream.withReader { Reader reader -> reader.text }
println response
