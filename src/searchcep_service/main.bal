import ballerina/http;
import ballerina/jsonutils;
import wso2/soap;

soap:Soap11Client soapClient = new("https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wdsl");
@http:ServiceConfig {basePath: "/"}

service search on new http:Listener(9090) {
    @http:ResourceConfig { methods: ["GET"], path: "cep/{cep}" }

    resource function consultaCEP( http:Caller caller, http:Request request, string cep ) {
        xmlns "http://cliente.bean.master.sigep.bsb.correios.com.br/" as cli;
        xml payload = xml `<cli:consultaCEP><cep>${cep}</cep></cli:consultaCEP>`;

        soap:SoapResponse soapResponse = checkpanic soapClient->sendReceive (<@untainted> payload, "");
        xml responsePayload = checkpanic soapResponse.httpResponse.getXmlPayload(); 
        http:Response response = new;
        response.setJsonPayload(<@untainted> checkpanic jsonutils:fromXML(responsePayload.Body.consultaCEPResponse, {preserveNamespaces: false}));
        error? respond = caller->respond(response);
    }
}