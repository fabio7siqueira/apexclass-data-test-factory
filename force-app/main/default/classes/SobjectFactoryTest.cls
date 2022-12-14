public without sharing class SobjectFactoryTest {

    @AuraEnabled
    public static String generateMethodToFactorySobject(String recordId) {
        try {
            Id sObjectId = Id.valueOf(recordId);
            String methodText = '';
            String objType = String.valueOf(sObjectId.getsobjecttype());
            String whereId = 'Id';
            String recordTypeId = '';
            String recordTypeDeveloperName = '';
            Map<String, SObjectField> mapFields = new Map<String, SObjectField>();

            SObject obj = DynamicDAO.findSObject(objType, whereId, recordId, null);
            
            mapFields = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
            recordTypeId = mapFields.containsKey('recordtypeid') ? String.valueOf(obj.get('recordtypeid')) : '';
            recordTypeDeveloperName = getRecordTypeDeveloperName(recordTypeId, objType);

            methodText = 'public static ' + objType + ' create' + objType + recordTypeDeveloperName + '() {\n';
            methodText += '\treturn new ' + objType + '(\n';
            for (String key: mapFields.keySet()) {
                String fieldType = String.valueOf(mapFields.get(key).getDescribe().getType());
                Object fieldData = obj.get(key);
                Boolean isUpdateableField = mapFields.get(key).getDescribe().isUpdateable();

                if (fieldData == null || fieldType == 'REFERENCE' || !isUpdateableField) {
                    continue;
                }

                methodText += '\t\t' + key + ' = ' + formatterField(fieldData, fieldType) + ',\n';
            }
            methodText.removeEnd(',');
            methodText += '\t)\n}';
            
            return methodText;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getRecordTypeDeveloperName(String recordTypeId, String sObjectApiName) {
        String recordTypeDeveloperName = '';

        if (String.isNotBlank(recordTypeId)) {
            recordTypeDeveloperName = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
        }

        return recordTypeDeveloperName;
    }

    private static String formatterField(Object fieldData, String fieldType) {
        String formattedFied = '';
        
        switch on fieldType {
            when 'STRING', 'PICKLIST', 'TEXTAREA', 'PHONE', 'EMAIL', 'URL' {
                formattedFied += '\'' + fieldData + '\'';
            }
            when 'DATE' {
                formattedFied += 'date.parse(\'' + fieldData + '\')';
            }
            when 'DATETIME' {
                formattedFied += 'datetime.parse(\'' + fieldData + '\')';
            }
            when else {
                formattedFied = String.valueOf(fieldData);
            }
        }
        
        return formattedFied;
    }

}