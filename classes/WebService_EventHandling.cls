@RestResource(urlMapping='/WebService_EventHandling/*')
global class WebService_EventHandling {
    
    // Get method will return all the event where Activity Date >= date received
    // https://domain.com/services/apexrest/WebService_EventHandling/2021-5-11
    // https://domain.com/services/apexrest/WebService_EventHandling/
    @HttpGet
    global static List<Event> getEvents() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String dateSubString = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);        
        Date searchEventDate = String.isNotBlank(dateSubString) ? Date.valueOf(dateSubString) : Date.newInstance(2020, 1, 1);
        List<Event> lstEvents = [SELECt Id, Subject, StartDateTime, EndDateTime, Location FROM Event WHERE ActivityDate >= :searchEventDate];
        return lstEvents;
    }
    
    // Post Method will create new Event
    @HttpPost
    global static String registerAttendeeeForEvent(String strEventId, String strFirstName, String strLastName, String strEmail, String strPhone) {
        try{
            // Create a new Contact Record
            Contact objCon = new Contact(FirstName = strFirstName != null ? strFirstName : null,
                                         LastName = strLastName,
                                         Email = strEmail != null ? strEmail : null,
                                         Phone = strPhone != null ? strPhone : null);
            insert objCon;
            
            // Get the Event record
            Event objEvent = [SELECt Id, Subject, ActivityDate FROM Event WHERE Id =: strEventId];
            
            // Create an Event Relation record with selected Event
            EventRelation objEventRel = new EventRelation(RelationId = objCon.Id, EventId = objEvent.id, IsInvitee = true);
            insert objEventRel;
            
            return 'Successfully Registered for the Event';
        }
        catch(Exception ex) {
            return ex.getMessage();
        }
    }
}