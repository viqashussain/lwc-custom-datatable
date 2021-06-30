public class TestHelper {
    public static Account createAccount()
    {
        Account account = new Account();
        account.Name = 'test account';
        
        account.BillingCountry = 'United States';
        account.BillingPostalCode = getRandomString();
        account.BillingCity = getRandomString();
        
        insert account;
        
        return account;
    }
    
    static string getRandomString()
    {
        final String chars = 'abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 7) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    public static Account createAccount(string name)
    {
        Account account = new Account();
        account.BillingCountry = 'United States';
        account.BillingPostalCode = getRandomString();
        account.BillingCity = getRandomString();
        account.Name = name;
        
        insert account;
        
        return account;
    }
    
    public static Contact createContact(Account account)
    {
        Contact contact = new Contact();
        contact.FirstName = 'test';
        contact.LastName = 'contact';
        contact.AccountId = account.Id;
        contact.Email = getRandomString() + '@ag-grid.com';
        
        insert contact; 
        
        return contact;
    } 
    
    public static Opportunity createOpportunity(Account account, Contact contact)
    {
        Opportunity opp = new Opportunity();
        opp.Account = account;
        opp.AccountId = account.Id;
        opp.Account.RecordTypeId = account.RecordTypeId;
        opp.Name = 'test opp';
        opp.StageName = 'Proposal';
        opp.CloseDate = system.today();   
        opp.QuoteEcommReference__c = 'abc';
        
        insert opp;
        
        OpportunityContactRole oppContactRole = new OpportunityContactRole();
        oppContactRole.contactId = contact.Id;
        oppContactRole.IsPrimary = true;
        oppContactRole.OpportunityId = opp.Id;
        oppContactRole.Role = 'License Holder';
        
        insert oppContactRole;
        
        return opp;
    }
    
    public static void createContactRole(Contact contact, Opportunity opp, string role)
    {
        OpportunityContactRole oppContactRole = new OpportunityContactRole();
        oppContactRole.contactId = contact.Id;
        oppContactRole.Contact = contact;
        oppContactRole.OpportunityId = opp.Id;
        oppContactRole.Role = role;
        
        insert oppContactRole;
    }
    
    public static void createLicenseHolderToAssetRelationship(Contact contact, Opportunity opp, Asset asset)
    {
        License_Holder_Asset__c lha = new License_Holder_Asset__c();
        lha.License_Holder_Contact__c = contact.Id;
        lha.Opportunity__c = opp.Id;
        lha.Asset__c = asset.Id;
        
        insert lha;
    }
    
    public static Asset createAsset(Opportunity opp)
    {
        Asset asset = createAsset(opp.AccountId, opp.ContactId);
        asset.Creator_Opportunity__c = opp.Id;
        
        update asset;
        
        return asset;
    }
    
    public static Asset createAsset(string accountId, string contactId)
    {
        Asset asset = new Asset();
        asset.Name = 'test asset';
        asset.AccountId = accountId;
        asset.Start__c = System.today();
        asset.Period__c = 1;
        asset.License_Key__c = 'MyLicenseKey';
        asset.ContactId = contactId;
        asset.Developer_Count__c = 10;
        asset.Deployment_Count__c = 5;
        asset.Developer_Type__c = 'Multiple Applications';
        asset.Application_Name__c = 'Test App';
        asset.Status = 'Proposal';
        
        insert asset;
        
        return asset;
    }
    
    public static AssetRelationship createAssetRelationship(string assetId, string relatedAssetId)
    {
        AssetRelationship ar = new AssetRelationship();
        ar.AssetId = assetId;
        ar.RelatedAssetId = relatedAssetId;
        
        insert ar;
        
        return ar;
    }
    
    public static Quote createQuote(Opportunity opp)
    {
        Quote quote = new Quote();
        quote.Name = 'test quote';
        quote.OpportunityId = opp.Id;
        quote.Opportunity = opp;
        quote.Status = 'Presented';
        
        insert quote; 
        
        return quote;
    }
    
    public static Quote createQuote(Opportunity opp, Pricebook2 pb)
    {
        Quote quote = createQuote(opp);
        quote.Pricebook2Id = pb.Id;
        
        update quote; 
        
        return quote;
    }
    
    public static EmailMessage createEmailMessage(string relatedId)
    {
        EmailMessage emailMessageObject = new EmailMessage();
        emailMessageObject.Subject = 'test subject';
        emailMessageObject.FromAddress = 'test@ag-grid.com';
        emailMessageObject.FromName = 'test user';
        emailMessageObject.HtmlBody = 'test email body';
        emailMessageObject.MessageDate = System.Now();
        emailMessageObject.RelatedToId = relatedId;
        emailMessageObject.ToAddress = 'toUser@ag-grid.com';
        
        insert emailMessageObject;
        
        return emailMessageObject;
    }
    
    public static Product2 createProductBySku(string sku)
    {
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Product_Group__c = 'Development';
        p.Family = 'Renewal';
        p.Product_Revenue_Type__c = 'Renewal_1st_Year';
        p.StockKeepingUnit = 'TEST' + sku;
        p.ProductCode = sku;
        p.IsActive = true;
        
        System.debug([SELECT stockkeepingunit FROM Product2]);
        
        insert p;
        
        PriceBookEntry standardPbe = new PriceBookEntry();
        standardPbe.Pricebook2Id = Test.getStandardPricebookId();
        standardPbe.UnitPrice = 100;
        standardPbe.Product2Id = p.Id;
        standardPbe.IsActive = true;
        
        insert standardPbe;
        
        return p;
    }
    
    public static PriceBook2 createPriceBook()
    {
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'Test Pricebook';
        pb.IsActive = true;
        
        insert pb;
        
        return pb;
    }
    
    public static PriceBookEntry createStandardPricebookEntry(Product2 p)
    {
        PriceBookEntry standardPbe = new PriceBookEntry();
        standardPbe.Pricebook2Id = Test.getStandardPricebookId();
        standardPbe.UnitPrice = 100;
        standardPbe.Product2Id = p.Id;
        standardPbe.IsActive = true;
        
        insert standardPbe;
        
        return standardPbe;
    }
    
    public static PriceBookEntry createPricebookEntry(Product2 p, Pricebook2 pricebook)
    {
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Pricebook2Id = pricebook.Id;
        pbe.UnitPrice = 100;
        pbe.Product2Id = p.Id;
        pbe.IsActive = true;
        
        insert pbe;
        
        return pbe;
    }
    
    public static QuoteLineItem createQuoteLineItem(Quote quote, PriceBookEntry pbe, Product2 p)
    {
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = quote.Id;
        qli.Quantity = 10;
        qli.UnitPrice = 100;
        
        List<PriceBookEntry> pbes = [SELECT Id FROM PriceBookEntry WHERE Product2Id =: p.Id AND Pricebook2Id !=: Test.getStandardPricebookId()];
        
        if (pbes.size() == 0)
        {
            qli.PricebookEntryId = pbe.Id;
        }
        else
        {
            qli.PricebookEntryId = pbes[0].Id;
        }
        
        insert qli;
        
        return qli;
    }
    
    public static QuoteLineItem createQuoteLineItem(Quote quote, PriceBookEntry pbe)
    {
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = quote.Id;
        qli.Quantity = 10;
        qli.UnitPrice = 100;
        qli.PricebookEntryId = pbe.Id;
        
        insert qli;
        
        return qli;
    }
    
    public static Bread_Winner__Invoice__c createInvoiceForAccount(Account acc)
    {
        Bread_Winner__Invoice__c inv = new Bread_Winner__Invoice__c();
        inv.Bread_Winner__Account__c = acc.Id;
        inv.Bread_Winner__Status__c = 'PAID';
        inv.Bread_Winner__Due_Date__c = System.today().addMonths(-1);
        
        insert inv;
        return inv;
    }
}