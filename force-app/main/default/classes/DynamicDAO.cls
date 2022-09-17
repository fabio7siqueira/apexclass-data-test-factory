public with sharing class DynamicDAO {

    public static List<SObject> getAllFieldsFromWhereId(String objectName, String whereId, String recordId, String orderBy) {
        if (orderBy == null) {
            orderBy = '';
        }
        return Database.query('SELECT ' + fieldCommaList(objectName) + ' FROM ' + objectName + ' WHERE ' + whereId + ' = :recordId ' + orderBy);   
    }

    private static string fieldCommaList(String objectName) {
        Set<String> questionFieldList = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet();
        List<String> strList = new List<String>();
        strList.addAll(questionFieldList);
        return STRING.join(strList,',');
    }

}