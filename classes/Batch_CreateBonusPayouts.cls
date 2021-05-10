global class Batch_CreateBonusPayouts implements Database.Batchable<sObject> {
    
    DateTime currentDateTime;
    Decimal Days_Req_For_First_Month;
    Decimal Days_Req_For_Last_Month;
    
    global Batch_CreateBonusPayouts() {
        currentDateTime = System.now();
        
        Bonus_BatchSetting__c bonusBatchSetting = Bonus_BatchSetting__c.getOrgDefaults();
        Days_Req_For_First_Month = bonusBatchSetting.Days_Req_For_First_Month__c;
        Days_Req_For_Last_Month = bonusBatchSetting.Days_Req_For_Last_Month__c;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Bonus_BatchSetting__c bonusBatchSetting = Bonus_BatchSetting__c.getOrgDefaults();
        DateTime batchLastRun;
        if(bonusBatchSetting.Last_Run_Date__c != null) batchLastRun = bonusBatchSetting.Last_Run_Date__c;
        else batchLastRun = Datetime.newinstance(2020, 12, 1, 0, 1, 1);
        
        String strQuery = 'SELECT Id, Name, Bonus_Start_Date__c, Bonus_End_Date__c From Bonus__c WHERE LastModifiedDate >= :batchLastRun';
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Bonus__c> lstBonuses) {
        try{
            // Get existing Bonus Payouts for the Bonuses
            List<Bonus_Payout__c> lstexistingPayouts = [Select Id, Bonus__c, Payout_Date__c FROM Bonus_Payout__c Order By Payout_Date__c DESC];
            // Delete the existing bonus payout records:
            Database.delete(lstexistingPayouts, false);
            
            List<Bonus_Payout__c> lstBonusPayoutsToCreate = new List<Bonus_Payout__c>();
            for(Bonus__c objBonus : lstBonuses) {
                Date bonusStartDate = objBonus.Bonus_Start_Date__c;
                Date bonusEndDate = objBonus.Bonus_End_Date__c;
                
                // Starting Month
                if((bonusStartDate.daysBetween(bonusStartDate.addMonths(+1).toStartOfMonth().addDays(-1))+1) >= (Integer)Days_Req_For_First_Month) {
                    lstBonusPayoutsToCreate.add(new Bonus_Payout__c(Bonus__c=objBonus.Id, Payout_Date__c=bonusStartDate.addMonths(+1).toStartOfMonth().addDays(-1)));
                }
                
                for(Date intDate = bonusStartDate.addMonths(+1) ; (intDate < bonusEndDate && intDate.month() != bonusEndDate.month()); intDate=intDate.addMonths(+1)) {
                    Date PayoutDate = Date.newinstance(intDate.year(), intDate.month(), (intDate.addMonths(+1).toStartOfMonth().addDays(-1)).day());
                    lstBonusPayoutsToCreate.add(new Bonus_Payout__c(Bonus__c=objBonus.Id, Payout_Date__c=PayoutDate));
                }
                
                // Last Month
                if(bonusEndDate.day() >= (Integer)Days_Req_For_Last_Month) {
                    lstBonusPayoutsToCreate.add(new Bonus_Payout__c(Bonus__c=objBonus.Id, Payout_Date__c=bonusEndDate));
                }
            }
            Database.insert(lstBonusPayoutsToCreate, false);
        } catch(Exception ex) {
            throw ex;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        Bonus_BatchSetting__c bonusBatchSetting = Bonus_BatchSetting__c.getOrgDefaults();
        bonusBatchSetting.Last_Run_Date__c = this.currentDateTime;
        update bonusBatchSetting;
    }
}