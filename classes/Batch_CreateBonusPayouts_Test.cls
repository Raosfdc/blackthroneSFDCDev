@IsTest
public class Batch_CreateBonusPayouts_Test {

    /** 
     * Test Cases:
     * Bonus with Start & End Date matching with Custom setting
     * Bonus with Start & End Date not matching with the custom setting
     * Bonus with Start date in current year & end date in next year
     */
    
    @TestSetup
    private static void createTestData() {
        
    }
    
    @isTest
    static void test_executeBatch() {
        Test.startTest();
        DataBase.executeBatch(new Batch_CreateBonusPayouts(), 100);
        Test.stopTest();
    }

    @isTest
    static void test_scheduleBatch() {
        DateTime currentDateTime = System.now();
        // Custom Setting Record
        Bonus_BatchSetting__c bonusBatchSetting = new Bonus_BatchSetting__c(
            Scheduler_Cron_Expression__c = '0 0 23 * * ? *', // run everyday at 10PM
            Last_Run_Date__c = Datetime.newInstance(2020, 1, 1, 0, 0, 1),
            Batch_Size__c = 100,
            Days_Req_For_First_Month__c = 15,
            Days_Req_For_Last_Month__c = 15
        );
        insert bonusBatchSetting;
        
        Test.startTest();
        Batch_CreateBonusPayouts_Scheduler.scheduleThisJob();
        Test.stopTest();
    }
}