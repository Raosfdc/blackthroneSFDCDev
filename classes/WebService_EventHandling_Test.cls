@IsTest
public class WebService_EventHandling_Test {
    
    @TestSetup
    static void createTestData() {
        createTestRecord();
    }

    @isTest
    static void test_getEvents() {
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri = 'https://capitalone-5b-dev-ed.my.salesforce.com/services/apexrest/WebService_EventHandling/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        // Call the method to test
        List<Event> lstEvent = WebService_EventHandling.getEvents();
        System.assert(lstEvent.size() != null);
    }
    
    @isTest
    static void test_registerAttendeeeForEvent() {
        List<Event> lstEvent = [SELECT Id, Subject, ActivityDate FROM Event];
        WebService_EventHandling.registerAttendeeeForEvent(lstEvent[0].Id, 'Test', 'Attendee 1', 'test1@test.com', '123456789');
        WebService_EventHandling.registerAttendeeeForEvent(lstEvent[1].Id, 'Test', 'Attendee 2', 'test1@test.com', '123456789');
        WebService_EventHandling.registerAttendeeeForEvent(lstEvent[2].Id, 'Test', 'Attendee 3', 'test1@test.com', '123456789');
        
        System.assert([SELECT EventId, Relation.name, IsInvitee FROM EventRelation WHERE EventId =: lstEvent[0].Id AND Relation.name LIKE 'TEST Attendee %' LIMIT 1].Relation.name == 'Test Attendeee 1');
        System.assert([SELECT EventId, Relation.name, IsInvitee FROM EventRelation WHERE EventId =: lstEvent[1].Id AND Relation.name LIKE 'TEST Attendee %' LIMIT 1].Relation.name == 'Test Attendeee 2');
        System.assert([SELECT EventId, Relation.name, IsInvitee FROM EventRelation WHERE EventId =: lstEvent[2].Id AND Relation.name LIKE 'TEST Attendee %' LIMIT 1].Relation.name == 'Test Attendeee 3');
    }
    
    static void createTestRecord() {
        List<Event> lstEvent = new List<Event>();
        Date todayDate = Date.today();
        for(Integer i=1; i<12; i++) {
            lstEvent.add(new Event(Subject='Test Event '+i, 
                         StartDateTime = DateTime.newInstance(todayDate.year(), i, 1, 0, 1, 1),
                         EndDateTime = DateTime.newInstance(todayDate.year(), i, 2, 0, 23, 59)));
            lstEvent.add(new Event(Subject='Test Event '+i, 
                         StartDateTime = DateTime.newInstance(todayDate.year(), i, 15, 0, 1, 1),
                         EndDateTime = DateTime.newInstance(todayDate.year(), i, 16, 0, 23, 59)));
        }
        insert lstEvent;
    }
}