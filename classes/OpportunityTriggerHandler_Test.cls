@IsTest
public class OpportunityTriggerHandler_Test {
    
    private static Map<String,Schema.RecordTypeInfo> mapOppRecordTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
    
    @TestSetup
    private static void createTestData() {
        //Insert Account
        Account objAcc = new Account(Name='Test Account', CustomField__c = 'Test Field');
        insert objAcc;
        
        // Create Test Opp Records
        List<Opportunity> lstOpps = new List<Opportunity>();
        for(Integer i=1; i<=10; i++) {
            lstOpps.add(new Opportunity(RecordTypeId = mapOppRecordTypes?.get('Non_Renewal')?.getRecordTypeId(),
                                        Name='Test Opp '+i, 
                                        StageName = 'Prospecting',
                                        CloseDate = i>5 ? Date.today().addMonths(-1) : Date.today().addMonths(i),
                                        AccountId = objAcc.Id));
        }
        insert lstOpps;
    }
    
    @IsTest
    private static void testOppTriggerAnatharao() {
        Test.startTest();
        List<Opportunity> lstOpps = [SELECT Id, RecordTypeId, StageName, CustomField__c FROM Opportunity];
        
        for(Integer i=0; i<10; i++) {	// Index of the list of opps
            System.assertEquals('Test Field', lstOpps[i].CustomField__c);
            
            if(i>5) {
                System.assertEquals(mapOppRecordTypes?.get('Renewal')?.getRecordTypeId(), lstOpps[i].RecordTypeId);
                System.assertEquals('Closed', lstOpps[i].StageName);
            }
        }
        
        // Consider some opp where closed date is less than today then the below assertion will satisfy
        lstOpps[6].RecordTypeId = mapOppRecordTypes?.get('Insurance')?.getRecordTypeId();
        update lstOpps;
        System.assertEquals(mapOppRecordTypes?.get('Renewal')?.getRecordTypeId(), [SELECT RecordTypeId FROM Opportunity WHERE Id =: lstOpps[6].Id].RecordTypeId);
        Test.stopTest();
    }
}