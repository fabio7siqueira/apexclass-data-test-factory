public without sharing class SobjectFactoryTest {

    @AuraEnabled
    public static String generateMethodToFactorySobject(String recordId) {
        try {
            Id sObjectId = Id.valueOf(recordId);
            String methodText = '';
            String objType = String.valueOf(sObjectId.getsobjecttype());
            String whereId = 'Id';

            SObject obj;
            List<SObject> objList = DynamicDAO.getAllFieldsFromWhereId(objType, whereId, recordId, null);
            if (objList.isEmpty()) {
                return '';
            }
            obj = objList.get(0);
            
            Map<String, SObjectField> mapFields = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
            String recordTypeId = mapFields.containsKey('recordtypeid') ? String.valueOf(obj.get('recordtypeid')) : '';
            String recordTypeDeveloperName = getRecordTypeDeveloperName(recordTypeId, objType);

            methodText = 'public static ' + objType + ' create' + objType + recordTypeDeveloperName + '() {\n';
            methodText += '\treturn new ' + objType + '(\n';
            for (String key: mapFields.keySet()) {
                if (obj.get(key) == null || fieldsToScape().contains(key)) {
                    continue;
                }
                methodText += '\t\t' + key + ' = ' + obj.get(key) + ',\n';
            }
            methodText.removeEnd(',');
            methodText += '\t)\n}';
            return methodText;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Set<String> fieldsToScape() {
        return new Set<String>{
            'id', 'createdbyid', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 'systemmodstamp', 
            'lastactivitydate', 'lastvieweddate', 'lastreferenceddate'
        };
    }

    private static String getRecordTypeDeveloperName(String recordTypeId, String sObjectApiName) {
        String recordTypeDeveloperName = '';

        if (String.isNotBlank(recordTypeId)) {
            recordTypeDeveloperName = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
        }

        return recordTypeDeveloperName;
    }

}