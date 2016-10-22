//
//  SOAPManager.swift
//  Mod8Practica1
//
//  Created by Infraestructura on 21/10/16.
//  Copyright © 2016 dacalo. All rights reserved.
//

import Foundation

public class SOAPManager: NSObject, NSURLConnectionDelegate, NSXMLParserDelegate{
    //Constantes
    
    private let NODO_RESULTADOS: String = "NewDataSet"
    private let NODO_MUNICIPIO: String = "ReturnDataSet"
    private var municipios: NSMutableArray?
    private var municipio: NSMutableDictionary?
    private var guardaResultados: Bool = false
    private var esMunicipio: Bool = false
    private var nombreCampo: String?
    
    
    static let instance:SOAPManager = SOAPManager()
    private let wsURL = "http://edg3.mx/webservicessepomex/sepomex.asmx"
    private var datosRecibidos: NSMutableData?
    private var conexion: NSURLConnection?
    
    
    
    
    public func consultaMunicipios(estado: String)
    {
        let soapMun1 = "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><WMRegresaMunicipios xmlns=\"http://tempuri.org/\"><c_estado>"
        
        let soapMun2 = "</c_estado></WMRegresaMunicipios></soap:Body></soap:Envelope>"
        
        let soapMessage = soapMun1 + estado + soapMun2
    
    
        let laURL = NSURL(string: self.wsURL)!
        let elRequest = NSMutableURLRequest(URL: laURL)
        //Configurar request
        elRequest.HTTPMethod = "POST"
        elRequest.setValue("text/xml", forHTTPHeaderField:"Content-Type")
        let longitudMensaje = "\(soapMessage.characters.count)"
        elRequest.setValue(longitudMensaje, forHTTPHeaderField:"Content-Lenght")
        elRequest.setValue("http://tempuri.org/WMRegresaMunicipios", forHTTPHeaderField:"SOAPAction")
        
        
        
        elRequest.HTTPBody = soapMessage.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        self.datosRecibidos = NSMutableData(capacity: 0)
    
        self.conexion = NSURLConnection(request: elRequest, delegate: self)
    
        if self.conexion == nil
        {
            self.datosRecibidos = nil
            self.conexion = nil
            print("No se puede acceder al WS Estados")
        }
    }


    public func connection(connection: NSURLConnection, didFailWithError error: NSError){
        self.datosRecibidos = nil
        self.conexion = nil
        print("No se puede accederr al WS Estados: Error del servidor")
    }

    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse){
        //Ya se logró la conexión, preparando para recibir datos
        datosRecibidos?.length = 0
    }


    func connection(connection: NSURLConnection, didReceiveData data: NSData){
        datosRecibidos?.appendData(data)
    }

    func connectionDidFinishLoading(connection: NSURLConnection){
        //SOAP RESPONSE ES UN XML, IMPLEMENTAR PARSEO
        let responseSRT = NSString(data: self.datosRecibidos!, encoding: NSUTF8StringEncoding)
        print(responseSRT)
        
        let xmlParser = NSXMLParser(data: self.datosRecibidos!)
        xmlParser.delegate = self
        xmlParser.shouldResolveExternalEntities = true
        xmlParser.parse()
    }
    
    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == NODO_RESULTADOS{
            guardaResultados = true
        }
        
        if guardaResultados && elementName == NODO_MUNICIPIO{
            
            self.municipio = NSMutableDictionary()
            esMunicipio = true
        }
        nombreCampo = elementName
    }
    
    
    public func parser(parser: NSXMLParser, foundCharacters string: String) {
        if esMunicipio{
            municipio?.setObject(string, forKey: nombreCampo!)
        }
    }
    
    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == NODO_MUNICIPIO{
            if municipios == nil{
                municipios = NSMutableArray()
            }
            municipios!.addObject(municipio!)
            esMunicipio = false
        }
    }

    public func parserDidEndDocument(parser: NSXMLParser) {
        print("resultado, parseado: \(municipios?.description)")
    }

}