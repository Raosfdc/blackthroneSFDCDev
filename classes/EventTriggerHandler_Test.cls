@IsTest
public class EventTriggerHandler_Test {
    
    @IsTest
    static void test_EventMaxCount() {
        Profile systemAdminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        /*
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'user1';
        user.profileId = systemAdminProfile.id;
        user.username = 'testu1@test.com';
        user.email = 'testu1antharao@testu1.com';
        User.isActive = TRUE;
        User.TimeZoneSidKey = 'America/Chicago';
        User.Country = 'USA';
        insert user;
		*/
        
        User Objuser = [SELECT Id, Name FROM user WHERE profileId =: systemAdminProfile.Id LIMIT 1];
        System.runAs(Objuser) {
            // Create Custom Setting Record
            EventTriggerSetting__c eventSetting = new EventTriggerSetting__c(EachUserEventCount__c = 20);
            insert eventSetting;
            
            List<Event> lstEvent = new List<Event>();
            for(Integer i=1; i<20; i++) {
                lstEvent.add(new Event(Subject = 'Test Event ' + i));
            }
            insert lstEvent;
            
            try{
                insert new Event(Subject = 'Test Event 20');
            }catch(DmlException e){
                System.assert((e.getMessage()).containsIgnoreCase('Too many events created this month for user'));
            }
        }
    }
}