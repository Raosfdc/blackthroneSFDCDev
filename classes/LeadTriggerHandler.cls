public class LeadTriggerHandler {
    
    public void onBeforeUpdate(Map<Id, Lead> oldMapLead, Map<Id, Lead> newMapLead) {
        Set<String> setEmailsIds = new Set<String>();
        for(Lead aLead : newMapLead.values()) {
            setEmailsIds.add(aLead.Email);
        }
        
        List<Lead> leadList = [SELECT Id FROM Lead WHERE Email IN: setEmailsIds];
        for(Lead aLead : newMapLead.values()) {
            if(leadList.size() > 0) {
                aLead.addError('Duplicate Lead!');
            }
        }
    }
}