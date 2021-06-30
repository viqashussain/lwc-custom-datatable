@IsTest
public class AgGridDatatableControllerTests {
	@IsTest 
    public static void getTableColumnDefsForAccount()
    {
        Account account = TestHelper.createAccount();
        
        Test.startTest();
        string jsonResponse = AgGridDatatableController.getColumns('Id, Name, CurrencyIsoCode, NumberOfEmployees, OwnerId', account.Id);
        Test.stopTest();
        
        string expectedResponse = '[{"type":"id","label":"Account ID","initialWidth":125,"hideDefaultActions":true,"fieldName":"Id","editable":false},{"type":"string","label":"Account Name","initialWidth":null,"hideDefaultActions":true,"fieldName":"Name","editable":true},{"type":"picklist","label":"Account Currency","initialWidth":null,"hideDefaultActions":true,"fieldName":"CurrencyIsoCode","editable":true,"typeAttributes":{"value":{"fieldName":"CurrencyIsoCode"},"placeholder":"Select...","options":[{"value":"USD","label":"U.S. Dollar"}],"name":"CurrencyIsoCode","label":"Account Currency","context":{"fieldName":"Id"}}},{"type":"number","label":"Employees","initialWidth":null,"hideDefaultActions":true,"fieldName":"NumberOfEmployees","editable":true},{"type":"lookup","label":"Owner ID","initialWidth":null,"hideDefaultActions":true,"fieldName":"OwnerId","editable":true,"typeAttributes":{"valueId":{"fieldName":"OwnerId"},"uniqueId":{"fieldName":"Id"},"placeholder":"Select...","objectType":"User","label":"User","icon":"standard:user","filters":"","fields":"Name","fieldName":"OwnerId","displayFormat":"Name","displayFields":"Name","additionalSearchField":""},"initialWidth":500}]';
        
        System.assertEquals(expectedResponse, jsonResponse);
    }
    
    @IsTest 
    public static void getTypeAttributesForAddExistingRecord()
    {
        Account account = TestHelper.createAccount();
        
        Test.startTest();
        string jsonResponse = AgGridDatatableController.getTypeAttributesForAddExistingRecord(account.Id);
        Test.stopTest();
        
        string expectedResponse = '{"valueId":{"fieldName":"Id"},"uniqueId":{"fieldName":"Id"},"placeholder":"Select...","objectType":"Account","label":"Account","icon":"standard:account","filters":"","fields":"Name","fieldName":"Id","displayFormat":"Name","displayFields":"Name","additionalSearchField":""}';
        
        System.assertEquals(expectedResponse, jsonResponse);
    }
    
    @IsTest 
    public static void getRecord()
    {
        string accountName = 'My Test Account';
        Account account = TestHelper.createAccount();
        account.Name = accountName;
        update account;
        
        Test.startTest();
        string jsonResponse = AgGridDatatableController.getRecord(account.Id);
        Test.stopTest();
        
        System.assertEquals(true, jsonResponse.contains('"Name":"' + accountName + '"'));
        System.assertEquals(true, jsonResponse.contains('"Id":"' + account.Id + '"'));
    }
}