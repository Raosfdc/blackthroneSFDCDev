//Scheduler 	:	"Batch_CreateBonusPayouts_Scheduler.scheduleThisJob();"
//Run Now		:	"Database.executeBatch(new Batch_CreateBonusPayouts(), 100)"
global with sharing class Batch_CreateBonusPayouts_Scheduler implements Schedulable {
    
    Integer batchSize;

    global Batch_CreateBonusPayouts_Scheduler() {
        // Set the batch size from Custom setting
        this.batchSize = (Integer)Bonus_BatchSetting__c.getOrgDefaults().Batch_Size__c;
        if(this.batchSize == NULL){
            this.batchSize = 100;
        }
    }
    
    global static void scheduleThisJob() {
        // Set the cron expression from Custom setting
        String strCronExp = (String)Bonus_BatchSetting__c.getOrgDefaults().Scheduler_Cron_Expression__c;

        // Schedule the batch
        String jobID = System.schedule(Test.isRunningTest() ? 
                                        'Test Batch_CreateBonusPayouts' : 
                                        'Batch_CreateBonusPayouts', strCronExp, new Batch_CreateBonusPayouts_Scheduler());
    }

    global void execute(SchedulableContext sc) {
        ID batchprocessid = Database.executeBatch(new Batch_CreateBonusPayouts(), batchSize);
    }
}