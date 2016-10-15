//
//  NuevoRViewController.swift
//  Mod8Practica1
//
//  Created by Infraestructura on 15/10/16.
//  Copyright © 2016 dacalo. All rights reserved.
//

import UIKit

class NuevoRViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var estados: NSArray?
    var municipios: NSArray?
    var colonias: NSArray?
    var conexion:NSURLConnection?
    var datosRecibidos: NSMutableData?
    
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtApellidos: UITextField!
    @IBOutlet weak var txtFechaNacimiento: UITextField!
    @IBOutlet weak var txtCalleNumero: UITextField!
    @IBOutlet weak var txtColonia: UITextField!
    @IBOutlet weak var txtEstado: UITextField!
    @IBOutlet weak var txtMunicipio: UITextField!
    @IBOutlet weak var pickerFN: UIDatePicker!
    @IBOutlet weak var pickerEstados: UIPickerView!
    @IBOutlet weak var pickerMunicipios: UIPickerView!
    @IBOutlet weak var pickerColonias: UIPickerView!
    
    @IBAction func pickerDateChanged(sender: AnyObject) {
        let formato = NSDateFormatter()
        formato.dateFormat = "dd-MMM-yyyy"
        let fechaString = formato.stringFromDate(self.pickerFN.date)
        self.txtFechaNacimiento.text = fechaString
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if textField.isEqual(self.txtNombre) ||
            textField.isEqual(self.txtApellidos) ||
            textField.isEqual(self.txtCalleNumero){
            self.ocultarPicker()
            return true
        }
        else
        {
            txtNombre.resignFirstResponder()
            txtApellidos.resignFirstResponder()
            txtCalleNumero.resignFirstResponder()
            if textField.isEqual(self.txtFechaNacimiento){
                self.subeBajaPicker(self.pickerFN, subeObaja: true)
            }
            return false
        }
        
 
        /*
        return textField.isEqual(self.txtNombre) ||
               textField.isEqual(self.txtApellidos) ||
               textField.isEqual(txtCalleNumero)
        */
    }
    
    func subeBajaPicker(elPicker: UIView, subeObaja:Bool) {
        var elFrame: CGRect = elPicker.frame
        UIView.animateWithDuration(0.9){
            if subeObaja{
                elFrame.origin.y = CGRectGetMaxY(self.txtFechaNacimiento.frame)
                elPicker.hidden = false
            }
            else
            {
                elFrame.origin.y = CGRectGetMaxY(self.view.frame)
            }
            elPicker.frame = elFrame
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.ocultarPicker()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.txtNombre.delegate = self
        self.txtApellidos.delegate = self
        self.txtFechaNacimiento.delegate = self
        self.txtCalleNumero.delegate = self
        self.txtColonia.delegate = self
        self.txtEstado.delegate = self
        self.txtMunicipio.delegate = self
        self.pickerFN.hidden = true
        self.pickerEstados.delegate = self
        self.estados = NSArray()
        //Iniciallizar con datos temporales
        self.municipios = ["", "", ""]//NSArray()
        self.colonias = NSArray()
        
        //Todo: Revisar si este es el mejor momento para cargar el WS
        self.consultaEstados()
    }
    
    
    func ocultarPicker(){
        var unFram:CGRect
        unFram = self.pickerFN.frame
        self.pickerFN.frame = CGRectMake(unFram.origin.x, CGRectGetMaxY(self.view.frame), unFram.size.width, unFram.size.height)
        self.pickerFN.hidden = true
    }
    
    func consultaEstados(){
        let urlString = "http://edg3.mx/webservicessepomex/wmregresaestados.php"
        let laURL = NSURL(string: urlString)!
        let elRequest = NSURLRequest(URL: laURL)
        self.datosRecibidos = NSMutableData(capacity: 0)
        self.conexion = NSURLConnection(request: elRequest, delegate: self)
        
        if self.conexion == nil{
            self.datosRecibidos = nil
            self.conexion = nil
            print("No se puede acceder al WS Estados")
        }
        
    }
    
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError){
        datosRecibidos = nil
        conexion = nil
        print("No se puede accederr al WS Estados: Error del servidor")
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData){
        datosRecibidos?.length = 0
    }
    
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData){
        datosRecibidos?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection){
        do{
            let arregloRecibido = try NSJSONSerialization.JSONObjectWithData(datosRecibidos!, options: .AllowFragments) as! NSArray
            estados = arregloRecibido
            pickerEstados.reloadAllComponents()
        }
        catch{
            print("Error al recibir")
        }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if pickerEstados.isEqual(pickerView)
        {
            return estados!.count
        }
        else if pickerMunicipios.isEqual(pickerView)
        {
            return municipios!.count
        }
        else if pickerColonias.isEqual(pickerView)
        {
            return colonias!.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if pickerEstados.isEqual(pickerView)
        {
            return (estados![row],valueForKey("nombreEstado") as! String)
            
        }
        else if pickerMunicipios.isEqual(pickerView)
        {
            rreturn (municipios![row]valouForKey("nombreEstado") as! String)
        }
        else if pickerColonias.isEqual(pickerView)
        {
            return (colonias![row] as! String)
        }
    }

    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
