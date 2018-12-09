def CAUSE_NOTE = "手动触发"
def firstLine = currentBuild.getLogFile().newReader().readLine()
if (firstLine.contains("note:")){
   CAUSE_NOTE = firstLine.split("note:")[-1]
}
def map = ["CAUSE_NOTE": CAUSE_NOTE  ]
return map
