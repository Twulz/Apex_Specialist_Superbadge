@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {

        String equipment_response = '[{"_id":"12345","replacement":true,"quantity":100,"name":"Breaker 25A","maintenanceperiod":0,"lifespan":0,"cost":30,"sku":"100012"},{"_id":"54321","replacement":true,"quantity":150,"name":"Switch","maintenanceperiod":0,"lifespan":0,"cost":100,"sku":"100013"}]';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(equipment_response);
        res.setStatusCode(200);
        return res;
    }
}