@IsTest
public class LeadTriggerHandler_Test {

    @TestSetup
    private static void createTestData() {
        //Insert Account
        Account objAcc = new Account(Name='Test Account');
        insert objAcc;
        
        // Insert Lead
        List<Lead> lstLeads = new List<Lead>();
        for(Integer i=1; i<=10; i++) {
            lstLeads.add(new Lead(FirstName = 'Test', LastName = 'Lead '+i, Email = 'testlead'+i+'@test.com', Company = (String)objAcc.Id));
        }
        insert lstLeads;
    }
    
    @IsTest
    private static void testDuplicateLeads() {
        List<Lead> lstLeads = [SELECT Id, Name, Email FROM Lead];
        lstLeads[0].Email = 'testLead5@test.com';
        
        try{
            update lstLeads[0];
        } catch(Exception ex) {
            System.assertEquals(true, (ex.getMessage()).containsIgnoreCase('Duplicate Lead!'));
        }
    }
}