public class LookupController {

    @AuraEnabled(cacheable=true)
    public static List<sObject> lookUp(String searchTerm, String objectName, String filters, string additionalSearchField, String recordId, String fields) {
        system.debug('fields: ' + fields);

        Integer limitNum = 3;

        String finalQuery = 'SELECT ' + fields + ' FROM ' + objectName;

        if(String.isBlank(recordId)){
            if(String.isNotBlank(searchTerm)){
                if(String.isBlank(additionalSearchField)){
                    finalQuery += ' WHERE Name Like  \'%' + searchTerm + '%\' ';
                }
                else
                {
                 	finalQuery += ' WHERE (Name Like  \'%' + searchTerm + '%\' OR ' + additionalSearchField + ' Like  \'%' + searchTerm + '%\') ';   
                }
            }
            
            System.debug('finalQuery: ' + finalQuery);
            
            if(String.isNotBlank(filters)){
                finalQuery += String.isNotBlank(searchTerm) ? ' AND ' : ' WHERE ';
                finalQuery += filters;
            }
        }else{
            finalQuery += ' WHERE Id =  \'' + recordId + '\'';
        }

        finalQuery+= ' LIMIT ' + limitNum;

        System.debug('Final Query::::' + finalQuery);

        List<sObject> lookUpList = database.query(finalQuery);

        return lookUpList;  
    }
}