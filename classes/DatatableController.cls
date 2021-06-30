public with sharing class DatatableController {    
    @AuraEnabled(cacheable=true)
    public static string getColumns(string commaSeperatedColumnApiNames, Id sObjectId) {
        string sobjectType = sObjectId.getSObjectType().getDescribe().getName();
        List<string> columnApiNames = commaSeperatedColumnApiNames.deleteWhitespace().split(',');
        
        List<TableColumnDef> columnDefs = new List<TableColumnDef>();
        
        for (integer i = 0; i < columnApiNames.size(); i++)
        {
            string columnApiName = columnApiNames[i];
            Schema.DescribeFieldResult columnDesc = Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap().get(columnApiName).getDescribe();
            string columnType = String.valueOf(columnDesc.getType()).toLowercase();
            TableColumnDef columnDef = getTableColumnDefByType(columnType, columnDesc, columnApiName, sobjectType);
            columnDef.fieldName = columnApiName;
            
            columnDef.label = columnDesc.getLabel();
            
            if (columnType == 'picklist')
            {
                ((PicklistTableColumnDef)columnDef).typeAttributes = new PicklistTypeAttributes(columnDesc, columnApiName);
            }
            
            columnDef.type = getDatatableTypeFromSchemaType(columnType);
            
            // make the first column always non-editable
            if (i == 0)
            {
                columnDef.editable = false;
                columnDef.initialWidth = 125;
            }
            
            columnDefs.add(columnDef);
        }
        
        system.debug(JSON.serialize(columnDefs)); 
        
        return JSON.serialize(columnDefs);
    }
    
    @AuraEnabled(cacheable=true)
    public static string getTypeAttributesForAddExistingRecord(Id sObjectId)
    {
        string sobjectType = sObjectId.getSObjectType().getDescribe().getName();
        LookupTypeAttributes typeAttributes = new LookupTypeAttributes(sobjectType);
        
        return JSON.serialize(typeAttributes);
    }
    
    @AuraEnabled(cacheable=true)
    public static string getRecord(Id selectedId)
    {
        string sobjectType = selectedId.getSObjectType().getDescribe().getName();
        Map<String,Schema.SObjectField> allFields = selectedId.getSObjectType().getDescribe().fields.getMap();
        string fieldNames = '';
        for(String fieldName : allFields.keyset()){
            Schema.DescribeFieldResult dfr = allFields.get(fieldName).getDescribe();
            fieldNames += dfr.getName();
            fieldNames += ',';
        }
        
        fieldNames = fieldNames.substring(0, fieldNames.length() - 1);
        
        SObject retrievedObject = Database.query('SELECT ' + fieldNames + ' FROM ' + sobjectType)[0];
        
        return JSON.serialize(retrievedObject);
    }
    
    static TableColumnDef getTableColumnDefByType(string columnType, Schema.DescribeFieldResult columnDesc, string columnApiName, string sObjectTypeName)
    {
        if (columnType == 'picklist')
        {
            return new PicklistTableColumnDef(columnDesc, columnApiName);
        }
        else if (columnType == 'reference')
        {
            return new LookupTableColumnDef(columnDesc, columnApiName, sObjectTypeName);
        }
        return new TableColumnDef();
    }
    
    static string getDatatableTypeFromSchemaType(string fieldType)
    {
        if (fieldType == 'date')
        {
            return 'date-local';
        }
        else if (fieldType == 'double' || fieldType == 'Integer' || fieldType == 'Long')
        {
            return 'number';
        }
        else if (fieldType == 'reference')
        {
            return 'lookup';
        }
        return fieldType;
    }
    
    static List<PicklistEntry> getPickListValuesIntoList(DescribeFieldResult columnDesc){
       List<PicklistEntry> pickListValuesList= new List<PicklistEntry>();
        
		List<Schema.PicklistEntry> ple = columnDesc.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal);
		}     
		return pickListValuesList;
    }
    
    private virtual class TableColumnDef
    {
        public string label { get; set; }
        public string fieldName { get; set; }
        public string type { get; set; }
        public boolean editable = true;
        public boolean hideDefaultActions = true;
        public Integer initialWidth { get; set; }
    }
    
    private class PicklistTableColumnDef extends TableColumnDef
    {
        public PicklistTypeAttributes typeAttributes { get; set; }
        
        PicklistTableColumnDef(DescribeFieldResult columnDesc, string columnApiName)
        {
            typeAttributes = new PicklistTypeAttributes(columnDesc, columnApiName);
        }
    }
    
    private class LookupTableColumnDef extends TableColumnDef
    {
        LookupTypeAttributes typeAttributes { get; set; }
        Integer initialWidth = 500;
        
        LookupTableColumnDef(DescribeFieldResult columnDesc, string columnApiName, string sObjectTypeName)
        {
            typeAttributes = new LookupTypeAttributes(columnDesc, columnApiName, sObjectTypeName);
        }
    }
    
    private class LookupTypeAttributes 
    {
        string placeholder { get; set; }
        ValueFieldName uniqueId { get; set; }
        string objectType { get; set; }
        string icon { get; set; }
        string displayFields { get; set; }
        string displayFormat { get; set; }
        ValueFieldName valueId { get; set; }
        string filters { get; set; }
        string label { get; set; }
        string fieldName { get; set; }
        string additionalSearchField = '';
        string fields = 'Name';
        
        LookupTypeAttributes(DescribeFieldResult columnDesc, string columnApiName, string sObjectTypeName)
        {
            // get the type of the lookup object
            // the object will always be a lookup
            string lookupObjectType = String.valueOf(columnDesc.getReferenceTo()[0]);
            
            placeholder = 'Select...';
            uniqueId = new ValueFieldName('Id');
            objectType = lookupObjectType;
            if (lookupObjectType == 'Asset')
            {
                icon = 'standard:asset_object';
            }
            else
            {
                icon = 'standard:' + lookupObjectType.toLowerCase();
            }
            displayFields = 'Name';
            displayFormat = 'Name';
            filters = '';
            valueId = new ValueFieldName(columnApiName);
            label = lookupObjectType;
            fieldName = columnApiName;
            if (lookupObjectType == 'Contact')
            {
                additionalSearchField = 'Email';
                displayFields = 'Name, Email';
                displayFormat = 'Name, Email';
            }
        }
        
        LookupTypeAttributes(string sObjectTypeName)
        {            
            placeholder = 'Select...';
            uniqueId = new ValueFieldName('Id');
            objectType = sObjectTypeName;
            if (sObjectTypeName == 'Asset')
            {
                icon = 'standard:asset_object';
            }
            else
            {
                icon = 'standard:' + sObjectTypeName.toLowerCase();
            }
            displayFields = 'Name';
            displayFormat = 'Name';
            filters = '';
            valueId = new ValueFieldName('Id');
            label = sObjectTypeName;
            fieldName = 'Id';
            if (sObjectTypeName == 'Contact')
            {
                additionalSearchField = 'Email';
                displayFields = 'Name, Email';
                displayFormat = 'Name, Email';
            }
        }
    }
    
    private class PicklistTypeAttributes
    {
        string placeholder { get; set; }
        List<PicklistTypeAttributeOption> options { get; set; }
        ValueFieldName value { get; set; }
        ValueFieldName context { get; set; }
        string label { get; set; }
        string name { get; set; }
        
        PicklistTypeAttributes(DescribeFieldResult columnDesc, string columnApiName)
        {
            placeholder = 'Select...';
            value = new ValueFieldName(columnApiName);
            context = new ValueFieldName('Id');
            options = new List<PicklistTypeAttributeOption>();
            label = columnDesc.getLabel();
            name = columnApiName;
            
            List<PicklistEntry> picklistEntries = getPickListValuesIntoList(columnDesc);
            
            for (PicklistEntry pe: picklistEntries)
            {
                PicklistTypeAttributeOption option = new PicklistTypeAttributeOption(pe.getLabel(), pe.getValue());
                options.add(option);
            }
        }
    }
    
    private class ValueFieldName
    {
        string fieldName { get; set; }
            
        ValueFieldName(string columnApiName)
        {
            this.fieldName = columnApiName;
        }
    }
    
    private class PicklistTypeAttributeOption
    {
        string label { get; set; }
        string value { get; set; }
        
        PicklistTypeAttributeOption(string label, string value)
        {
            this.label = label;
            this.value = value;
        }
    }
}