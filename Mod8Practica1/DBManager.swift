//
//  DBManager.swift
//  Mod8Practica1
//
//  Created by Infraestructura on 14/10/16.
//  Copyright © 2016 dacalo. All rights reserved.
//

import Foundation
import CoreData

class DBManager{
    
    //Declaraciòn del singleton
    static let instance = DBManager()
    
    
    
    
    // si hay dos o mas argumentos, del segundo en adelante, el identificador del paràmetro se debe usar como etiqueta al invocar el método
    // func encuentraTodosLos(nombreEntidad: String, ordenadosPor: String)->NSArray{
    
    // Si no quiero que aparezca los identificadores como etiquetas, se agregan los caracteres "_ " antes de cada identificador
    
    func encuentraTodosLos(nombreEntidad: String, filtradosPor: NSPredicate)->NSArray{
        let elQuery: NSFetchRequest = NSFetchRequest()
        let laEntidad: NSEntityDescription = NSEntityDescription.entityForName(nombreEntidad, inManagedObjectContext: self.managedObjectContext!)!
        
        elQuery.entity = laEntidad
        elQuery.predicate = filtradosPor
        
        do{
            let result = try self.managedObjectContext!.executeFetchRequest(elQuery)
            return result as NSArray
        }
        catch{
            print("Error al ejecutar request")
            return NSArray()
        }
        
    }
    
    
    func encuentraTodosLos(nombreEntidad: String, _ ordenadosPor: String)->NSArray{
        
        let elQuery: NSFetchRequest = NSFetchRequest()
        let laEntidad: NSEntityDescription = NSEntityDescription.entityForName(nombreEntidad, inManagedObjectContext: self.managedObjectContext!)!
        elQuery.entity = laEntidad
        do{
            let result = try self.managedObjectContext!.executeFetchRequest(elQuery)
            return result as NSArray
        }
        catch{
            print("Error al ejecutar request")
            return NSArray()
        }
        
        
    }
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let persistence = self.persistentStore
        if persistence == nil{
            return nil
        }
        
        var moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        moc.persistentStoreCoordinator = persistence
        return moc
        
    }()
    
    
    lazy var managedObjectModel: NSManagedObjectModel? = {
        let modelURL = NSBundle.mainBundle().URLForResource("PetCens", withExtension: "momd")
        var model = NSManagedObjectModel(contentsOfURL: modelURL!)
        
        //Los archivos que se agregan al proyecto en tiempo de dieño, quedan ubicados en "Resources" y son de solo lectura.
        return model
    }()
    
    lazy var persistentStore: NSPersistentStoreCoordinator? = {
        let model = self.managedObjectModel
        if model == nil
        {
            return nil
        }
        
        let persist = NSPersistentStoreCoordinator(managedObjectModel: model!)
        // Encontrar la ubicación de las base de datos...
        
        let urlDeLaBD = self.directorioDocuments.URLByAppendingPathComponent("PetCens.sqlite")
        
        do{
            
            let opcionesDePersistencia = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            
            try persist.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL:urlDeLaBD, options: opcionesDePersistencia)
        }catch{
            print("no se puede abrir la base de datos")
            abort()//terminar la ejecución
        }
        
        
        return persist
    }()
    
    
    lazy var directorioDocuments: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        //return urls[urls.count - 1]//devuelve el último
        return urls[0]//devuelve el primero
    }()
    
    
}
