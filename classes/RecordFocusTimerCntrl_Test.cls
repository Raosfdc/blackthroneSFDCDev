@IsTest
public with sharing class RecordFocusTimerCntrl_Test {

    @TestSetup
    static void createTestData(){

        Opportunity opp = new opportunity(Name = 'Test Opp', CloseDate = Date.today().addDays(+10), StageName = 'Prospecting');
        insert opp;
    }

    @IsTest
    static void test_updateRecord() {
        Opportunity opp = [SELECT Id, Name FROM Opportunity];

        Test.startTest();
        RecordFocusTimerCntrl.updateRecord(opp.Id, 'Opportunity', 'Minute_Spent__c', 10);
        System.assertEquals(10, [SELECT Minute_Spent__c FROM Opportunity WHERE Id =: opp.Id].Minute_Spent__c);
        Test.stopTest();
    }
}