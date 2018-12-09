function mergeSql(){
    sql_list = []
    $('.track-detail-rollback-sql .CodeMirror-code pre').each((i,v) => sql_list.push(v.innerText))
    sql_list.length > 0 ? result_list.push(sql_list.join('\n')):''
    $('#track-event-detail-next').click()
}
result_list = []
do{
    mergeSql()
}while ($('#track-event-detail-next').attr('class').indexOf('disabled') == -1)
mergeSql()
window.copy(result_list.join('\n'))
