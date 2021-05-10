// Apex Controller for RecordFocusTimer LWC Component
public with sharing class RecordFocusTimerCntrl {

    // Update the field on object
    @AuraEnabled(Cacheable=false)
    public static string updateRecord(String currentRecordId, String currentSobjectApiName, String timerFieldApiName, Decimal currentTimeSpent){
        try {
            // Get the existing record data
            sObject exisitngSobj = (sObject)(Database.query('SELECT Id,' + timerFieldApiName + ' FROM ' + currentSobjectApiName + ' WHERE Id=\'' + currentRecordId + '\' LIMIT 1'));

            Decimal oldValue = exisitngSobj.get(timerFieldApiName) == null ? 0 : (Decimal)exisitngSobj.get(timerFieldApiName);
            exisitngSobj.put(timerFieldApiName, (oldValue + currentTimeSpent));

            update exisitngSobj;

            return '';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}