public class EventTriggerHandler {
    
    public void onBeforeInsert(List<Event> newList) {
        try{
            Integer monthNumber = Date.Today().Month();
            Integer yearNumber = Date.Today().Year();
            
            EventTriggerSetting__c mhc = EventTriggerSetting__c.getOrgDefaults();
            Decimal maxEvents = mhc.EachUserEventCount__c;
            
            Integer intmaxEvents = maxEvents.intValue();
            System.debug('maxEvents: '+intmaxEvents);
            
            User Usr = [select Name from user where id=:userinfo.getuserid()];
            
            List<Event> thisMonthEventList = [select id, CreatedById, CreatedDate from Event where 
                                              CALENDAR_YEAR(CreatedDate) =:yearNumber and 
                                              CALENDAR_MONTH(CreatedDate)=:monthNumber and 
                                              CreatedById =: UserInfo.GetUserId()];
            
            for(Event ev : newList) {
                if (thisMonthEventList.Size()>=intmaxEvents){
                    Trigger.New[0].addError('Too many events created this month for user '+Usr.Name+' : '+intmaxEvents);
                }
            }
        } catch(Exception ex) {
            System.debug('Execption occured while creating the event. Please contact your system Admin.');
        }
    }
}