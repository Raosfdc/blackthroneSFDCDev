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
        // Custom Setting Record
        Bonus_BatchSetting__c bonusBatchSetting = new Bonus_BatchSetting__c(
            Scheduler_Cron_Expression__c = '0 0 23 * * ? *', // run everyday at 10PM
            Last_Run_Date__c = Datetime.newInstance(2019, 1, 1, 0, 0, 1),
            Batch_Size__c = 100,
            Days_Req_For_First_Month__c = 15,
            Days_Req_For_Last_Month__c = 15
        );
        insert bonusBatchSetting;
        
        // Insert Bonus Records
        List<Bonus__c> lstBonuses = new List<Bonus__c>();
        
        // When Bonus Dates are more than the range
        for(Integer i=1; i<=25; i++) {
            lstBonuses.add(new Bonus__c(Name = 'Test Bonus '+i,
                                        Bonus_Start_Date__c = Date.newInstance(2020, 1, 1),
                                        Bonus_End_Date__c = Date.newInstance(2020, 3, 31)));
        }
        // When Bonus Dates just touches the range
        for(Integer i=26; i<=50; i++) {
            lstBonuses.add(new Bonus__c(Name = 'Test Bonus '+i,
                                        Bonus_Start_Date__c = Date.newInstance(2020, 1, 16),
                                        Bonus_End_Date__c = Date.newInstance(2020, 3, 15)));
        }
        // When Bonus Dates out of the range
        for(Integer i=51; i<=75; i++) {
            lstBonuses.add(new Bonus__c(Name = 'Test Bonus '+i,
                                        Bonus_Start_Date__c = Date.newInstance(2020, 1, 25),
                                        Bonus_End_Date__c = Date.newInstance(2020, 3, 10)));
        }
        // When Bonus Dates are moving from one year to another
        for(Integer i=76; i<=100; i++) {
            lstBonuses.add(new Bonus__c(Name = 'Test Bonus '+i,
                                        Bonus_Start_Date__c = Date.newInstance(2021, 10, 1),
                                        Bonus_End_Date__c = Date.newInstance(2022, 3, 31)));
        }
        insert lstBonuses;
    }
    
    @isTest
    static void test_executeBatch() {
        Test.startTest();
        DataBase.executeBatch(new Batch_CreateBonusPayouts(), 100);
        Test.stopTest();
        
        List<Bonus_Payout__c> b1 = [SELECT Id, Payout_Date__c FROM Bonus_Payout__c WHERE Bonus__r.Name = 'Test Bonus 1'];
        System.assert(b1.size() == 3);
        
        List<Bonus_Payout__c> b2 = [SELECT Id, Payout_Date__c FROM Bonus_Payout__c WHERE Bonus__r.Name = 'Test Bonus 27'];
        System.assert(b2.size() == 3);
        
        List<Bonus_Payout__c> b3 = [SELECT Id, Payout_Date__c FROM Bonus_Payout__c WHERE Bonus__r.Name = 'Test Bonus 53'];
        System.assert(b3.size() == 1);
        
        List<Bonus_Payout__c> b4 = [SELECT Id, Payout_Date__c FROM Bonus_Payout__c WHERE Bonus__r.Name = 'Test Bonus 78'];
        System.assert(b4.size() == 6);
    }

    @isTest
    static void test_scheduleBatch() {
        Test.startTest();
        Batch_CreateBonusPayouts_Scheduler.scheduleThisJob();
        Test.stopTest();
        
        List<Bonus_Payout__c> b1 = [SELECT Id, Payout_Date__c FROM Bonus_Payout__c WHERE Bonus__r.Name = 'Test Bonus 1'];
        System.assert(b1.size() == 3);
        
        List<Bonus_Payout__c> b2 = [SELECT Id, Payout_Date__c FROM Bonus_Payout__c WHERE Bonus__r.Name = 'Test Bonus 27'];
        System.assert(b2.size() == 3);
        
        List<Bonus_Payout__c> b3 = [SELECT Id, Payout_Date__c FROM Bonus_Payout__c WHERE Bonus__r.Name = 'Test Bonus 53'];
        System.assert(b3.size() == 1);
        
        List<Bonus_Payout__c> b4 = [SELECT Id, Payout_Date__c FROM Bonus_Payout__c WHERE Bonus__r.Name = 'Test Bonus 78'];
        System.assert(b4.size() == 6);
    }
}