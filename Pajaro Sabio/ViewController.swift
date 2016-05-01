//
//  ViewController.swift
//  Pajaro Sabio
//
//  Created by guitarrkurt on 30/04/16.
//  Copyright © 2016 guitarrkurt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
//MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!

//MARK: - Arrays
    var arrayPalabrasTweet: NSArray!
    
    let hashProba = NSMutableDictionary()
    let hashClase = NSMutableDictionary()
    let hashFrec = NSMutableDictionary()
    
    var arrayProbTweet = [Float]()
    
//MARK: - Propertys
    var tweetLeido = String()
    let NEUTRO = "NEUTRO"
    var PALRABRASTIENETWEET = 0
    var TOTALPALABRAS_BA = 0
    var TOTALPALABRAS_TG = 0
    var arrayCorpus: [String]!
    let textFromFile = String()
//MARK: - Constructor
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let textFromFile = readFileFromBundle("corpus", typeFile: "txt")
        if textFromFile != ""{
            print("Texto Leido: \(textFromFile)")
            
            arrayCorpus = textFromFile.componentsSeparatedByString("\n")
            print("arrayCorpus Separado En Filas: \(arrayCorpus)")
            
            totalPalabrasBA_y_TG(arrayCorpus)
            
            crearHash(hashClase, otroPara: hashProba, dadoUn: textFromFile)
            print("hashClase: \(hashClase)")
            print("hashProba: \(hashProba)")
        } else {
            print("error al leer textFromFile")
        }
        
        
    }
//MARK: - READ FILE FROM BUNDLE
    func readFileFromBundle(nameFile:String, typeFile: String) -> String{
        print("func readFileFromBundle(nameFile:String, typeFile: String) -> String")
        
        //Variables
        var textFromFile: String?
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource(nameFile, ofType: typeFile)
        
        //Acciones
        do {
            textFromFile = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        } catch {
            textFromFile = nil
        }
        if textFromFile != nil{
            return textFromFile!
        } else {
            print("Ocurrio un ERROR al leer el Archivo")
            return ""
        }
    }
//MARK: - CREAR HASHES
    func crearHash(hashClase: NSMutableDictionary, otroPara hashProba: NSMutableDictionary, dadoUn corpus: String) {
        print("func crearHashFromCorpus(corpus: String) -> NSDictionary")
        
        //Acciones
        print("Creacion Diccionarios")
        for i in 0 ..< arrayCorpus.count-1{
            
            let fila = arrayCorpus[i]
            print("Fila: \(fila)")
            
            print("Separando palabras tokeeaiser...")
            let arrayPalabrasFila = fila.componentsSeparatedByString(" ")
            print("Palabras Fila: \(arrayPalabrasFila)")
            
            print("Agregamos al Diccionario...")
            let palabra = arrayPalabrasFila[1] 
                print("Palabra: \(palabra)")
            
            let clase = "\(arrayPalabrasFila[0]) "
                print("Clase: \(clase)")
            
            let proba = "\(arrayPalabrasFila[4])"
                print("Proba: \(proba)")
            
            let frec = "\(arrayPalabrasFila[2])"
                print("Frec: \(frec)")
            
            print("Agregando al Diccionario...")
            if arrayCorpus[i] != ""{
                hashProba.setValue(proba, forKey: palabra)
                hashClase.setValue(clase, forKey: palabra)
                hashFrec.setValue(frec, forKey: palabra)
            } else {
                print("La FILA tiene una cadena vacia - ERROR")
            }
        }

    }
    
    
    @IBAction func calcularAction(sender: AnyObject) {
        principal()

    }
    
//MARK: RETORNA TIPO CLASE - Sino lo encuentra retorna NEUTRO
    func esBA_o_es_TG_dado(diccionario: NSMutableDictionary, conLa palabra: String) -> String{
        
        let clase: String? = diccionario.objectForKey(palabra) as? String
        
        if clase != nil{
            return clase!
        } else {
            return NEUTRO
        }
    }
    
//MARK: - SACAR PROBABILIDADES
    func agregarProbabilidad(proba: Float){
        arrayProbTweet.append(proba)
    }
    
//MARK: - GET TOTAL PALABRAS BA & TG
    func totalPalabrasBA_y_TG(arrayRows: [String]){

        //Acciones
        for i in 0 ..< arrayRows.count-1{
            
            let fila = arrayRows[i]
            print("Fila: \(fila)")
            
            print("Separando palabras tokeeaiser...")
            let arrayPalabrasFila = fila.componentsSeparatedByString(" ")
            print("Palabras Fila: \(arrayPalabrasFila)")
            
            let clase = "\(arrayPalabrasFila[0])"
            print("Clase: \(clase)")
            
            if clase == "TG"{
                self.TOTALPALABRAS_TG = Int(arrayPalabrasFila[3])!
            }
            
            if clase == "BA"{
                self.TOTALPALABRAS_BA = Int(arrayPalabrasFila[3])!
            }
            
            if (TOTALPALABRAS_BA != 0) && (TOTALPALABRAS_TG != 0) {
                break;
            }

        }

    }
//MARK: - SUAVIZADO
    func suavizadoToni(tweet: String) -> [Float]{
        //Variables
        let arrayPalabras = tweet.componentsSeparatedByString(" ")
        let palabrasTweet = arrayPalabras.count
        var newFrec = 0
        var arrayTotal = [Float]()
        //Constantes
        let nuevoTotalPal = self.TOTALPALABRAS_TG + palabrasTweet
        var pal = String()
        var newProb: Float! = Float()
        //Procedimiento
        if arrayPalabras.count != 0{
            for i in 0 ..< arrayPalabras.count{
                
                pal = arrayPalabras[i]
                let newFrecString =  hashFrec.objectForKey(pal) as! String
                newFrec = Int(newFrecString)!
                
                if newFrec != 0{
                    newFrec += 1
                    //Sacamos nueva probabilidad
                    newProb = (Float(newFrec)/Float(nuevoTotalPal))
                } else {
                    print("Error en suavizado el returno de una frecuencia es NIL")
                }
            
                
             actualizarSuavizado(newFrec, newTotalPala: nuevoTotalPal, newProbabilidad: newProb, dada: pal, paraLaClase: "TG ")
                
                arrayTotal.append(newProb)
            }
        } else {
            print("ERROR Tweet Vacio o no tiene espacios para separarlo")
        }
    
        return arrayTotal
    }
    
    func suavizadoBlanca(tweet: String) -> [Float]{
        //Variables
        let arrayPalabras = tweet.componentsSeparatedByString(" ")
        let palabrasTweet = arrayPalabras.count
        var newFrec = 0
        var arrayTotal = [Float]()
        //Constantes
        let nuevoTotalPal = self.TOTALPALABRAS_BA + palabrasTweet
        var pal = String()
        var newProb: Float! = Float()
        //Procedimiento
        if arrayPalabras.count != 0{
            for i in 0 ..< arrayPalabras.count{
                
                pal = arrayPalabras[i]
                let newFrecString =  hashFrec.objectForKey(pal) as! String
                newFrec = Int(newFrecString)!
                
                if newFrec != 0{
                    newFrec += 1
                    //Sacamos nueva probabilidad
                    newProb = (Float(newFrec)/Float(nuevoTotalPal))
                } else {
                    print("Error en suavizado el returno de una frecuencia es NIL")
                }
                
                
                actualizarSuavizado(newFrec, newTotalPala: nuevoTotalPal, newProbabilidad: newProb, dada: pal, paraLaClase: "BA ")
                
                arrayTotal.append(newProb)
            }
        } else {
            print("ERROR Tweet Vacio o no tiene espacios para separarlo")
        }
        
        return arrayTotal
    }
    func suavizadoBlancaNuevasPalabras(tweet: String) -> [Float]{
        //Variables
        let arrayPalabras = tweet.componentsSeparatedByString(" ")
        let palabrasTweet = arrayPalabras.count
        let nuevoTotalPal = self.TOTALPALABRAS_BA + palabrasTweet
        var newFrec = 0
        var arrayTotal = [Float]()
        var pal = String()
        var newProb: Float! = Float()
        //Procedimiento
        if arrayPalabras.count != 0{
            for i in 0 ..< arrayPalabras.count{

                pal = arrayPalabras[i]
        
                //Verificamos si la palabra existe
                let clase: String? = hashClase.objectForKey(pal) as? String
                if clase != nil{
                    let newFrecString =  hashFrec.objectForKey(pal) as! String
                    newFrec = Int(newFrecString)!
                    
                    if newFrec != 0{
                        newFrec += 1
                        //Sacamos nueva probabilidad
                        newProb = (Float(newFrec)/Float(nuevoTotalPal))
                    } else {
                        print("Error en suavizado el returno de una frecuencia es NIL")
                    }
                    
                    actualizarSuavizado(newFrec, newTotalPala: nuevoTotalPal, newProbabilidad: newProb, dada: pal, paraLaClase: "BA ")
                    
                    arrayTotal.append(newProb)
                    
                } else {
                    //Es una palabra nueva
                    newProb = agregarPalabraNueva_Hashes(pal, newTotalPala: nuevoTotalPal, clase: "BA ")
                    arrayTotal.append(newProb)
                }
            }
            
        } else {
            print("ERROR Tweet Vacio o no tiene espacios para separarlo")
        }

        return arrayTotal
    }
    func suavizadoToniNuevasPalabras(tweet: String) -> [Float]{
        //Variables
        let arrayPalabras = tweet.componentsSeparatedByString(" ")
        let palabrasTweet = arrayPalabras.count
        let nuevoTotalPal = self.TOTALPALABRAS_BA + palabrasTweet
        var newFrec = 0
        var arrayTotal = [Float]()
        var pal = String()
        var newProb: Float! = Float()
        //Procedimiento
        if arrayPalabras.count != 0{
            for i in 0 ..< arrayPalabras.count{
                
                pal = arrayPalabras[i]
                
                //Verificamos si la palabra existe
                let clase: String? = hashClase.objectForKey(pal) as? String
                if clase != nil{
                    let newFrecString =  hashFrec.objectForKey(pal) as! String
                    newFrec = Int(newFrecString)!
                    
                    if newFrec != 0{
                        newFrec += 1
                        //Sacamos nueva probabilidad
                        newProb = (Float(newFrec)/Float(nuevoTotalPal))
                    } else {
                        print("Error en suavizado el returno de una frecuencia es NIL")
                    }
                    
                    actualizarSuavizado(newFrec, newTotalPala: nuevoTotalPal, newProbabilidad: newProb, dada: pal, paraLaClase: "TG ")
                    
                    arrayTotal.append(newProb)
                    
                } else {
                    //Es una palabra nueva
                    newProb = agregarPalabraNueva_Hashes(pal, newTotalPala: nuevoTotalPal, clase: "TG ")
                    arrayTotal.append(newProb)
                }
            }
            
        } else {
            print("ERROR Tweet Vacio o no tiene espacios para separarlo")
        }
        
        return arrayTotal
    }
    func agregarPalabraNueva_Hashes(pal: String, newTotalPala: Int, clase:String) -> Float{
        var prob = Float()
        //Agregamos la CLASE
        if clase == "BA "{
            self.hashClase.setValue(clase, forKey: "BA ")
            //PROBABILIDAD
            prob = 1.0/Float(self.TOTALPALABRAS_BA)
            
            print("updatearTotaltiene: \(TOTALPALABRAS_BA)")
            updateTotalPalabrasBA(newTotalPala)
            print("updateadas: \(TOTALPALABRAS_BA)")
        }
        else if clase == "TG "{
            self.hashClase.setValue(clase, forKey: "TG ")
            prob = 1.0/Float(self.TOTALPALABRAS_TG)
            
            print("updatearTotaltiene: \(TOTALPALABRAS_TG)")
            updateTotalPalbrasTG(newTotalPala)
            print("updateadas: \(TOTALPALABRAS_TG)")
            
        } else {
            print("ERROR al agregar la clase")
        }
        //Agregamos la FRECUENCIA
            self.hashFrec.setValue("1", forKey: pal)
        //Agregamos la PROBABILIDAD
        if prob != 0{
            self.hashProba.setValue(prob, forKey: pal)
        } else {
            print("ERROR al agregar probabilidad")
        }
        

        return prob
    }
//MARK: - Actualizar Suavizado
    func actualizarSuavizado(newFrecuencia: Int, newTotalPala: Int, newProbabilidad: Float, dada palabra: String, paraLaClase clase: String){
        
        print("intentaCambiar: \(newFrecuencia)")
        
        self.hashFrec.setValue("\(newFrecuencia)", forKey: palabra)
        
        print("nuewFrec: \(self.hashFrec.objectForKey(palabra))")
        
        
        if clase == "TG "{
            print("updatearTotaltiene: \(TOTALPALABRAS_TG)")
            updateTotalPalbrasTG(newTotalPala)
            print("updateadas: \(TOTALPALABRAS_TG)")
        } else {
            print("updatearTotaltiene: \(TOTALPALABRAS_BA)")
            updateTotalPalabrasBA(newTotalPala)
            print("updateadas: \(TOTALPALABRAS_BA)")
        }

        
        print("Proba pretende: \(newProbabilidad)")
        self.hashProba.setValue("\(newProbabilidad)", forKey: palabra)
        print("updateada: \(self.hashProba.objectForKey(palabra))")
    }
    
//MARK: - No Pertenece A Ningun Candidato
    func tweetNoPerteneceANingunCandidato(tweet: String) -> Bool{
        //Variables
        let arrayPalabras = tweet.componentsSeparatedByString(" ")
        var result: Bool = true
        
        //Procedimiento
        if arrayPalabras.count != 0{
            for i in 0 ..< arrayPalabras.count{
                
                let palabra = arrayPalabras[i]
                let clase: String? = hashClase.objectForKey(palabra) as? String
                
                if clase != nil{
                    result =  false
                }
            }
        } else {
            print("ERROR Tweet Vacio o no tiene espacios para separarlo")
        }
        
        return result
    }
//MARK: - Tiene de Ambos
    func tweetTieneDeAmbos(tweet: String) -> Bool{
        //Variables
        let arrayPalabras = tweet.componentsSeparatedByString(" ")
        var result: Bool = false
        var palabrasToni = 0
        var palabrasBlanca = 0
        
        //Procedimiento
        if arrayPalabras.count != 0{
            for i in 0 ..< arrayPalabras.count{
                
                let palabra = arrayPalabras[i]
                let clase: String? = hashClase.objectForKey(palabra) as? String
                
                if clase != nil{
                    if clase == "TG "{
                        palabrasToni += 1
                    }
                    else if clase == "BA "{
                        palabrasBlanca += 1
                    }
                }
            }
        } else {
            print("ERROR Tweet Vacio o no tiene espacios para separarlo")
        }
        
        
        if (palabrasToni != 0) && (palabrasBlanca != 0) {
            result = true
        } else {
            result = false
        }
        
        return result
    }

//MARK: Es de BLANCA
    func tweetExclusivamenteDeBlanca(tweet: String) -> Bool{
        //Variables
        let arrayPalabras = tweet.componentsSeparatedByString(" ")
        var result: Bool = false
        var palabrasBlanca = 0
        
        //Procedimiento
        if arrayPalabras.count != 0{
            for i in 0 ..< arrayPalabras.count{
                
                let palabra = arrayPalabras[i]
                let clase: String? = hashClase.objectForKey(palabra) as? String
                
                if clase != nil{
                    if clase == "TG "{
                        return false
                    }
                    else if clase == "BA "{
                        palabrasBlanca += 1
                    }
                } else {
                    return false
                }
            }
        } else {
            print("ERROR Tweet Vacio o no tiene espacios para separarlo")
        }
        
        
        if palabrasBlanca == arrayPalabras.count {
            result = true
        }
        
        return result
    }
    
//MARK: Es de TONI
    func tweetExclusivamenteDeToni(tweet: String) -> Bool{
        //Variables
        let arrayPalabras = tweet.componentsSeparatedByString(" ")
        var result: Bool = false
        var palabrasToni = 0
        
        //Procedimiento
        if arrayPalabras.count != 0{
            for i in 0 ..< arrayPalabras.count{
                
                let palabra = arrayPalabras[i]
                let clase: String? = hashClase.objectForKey(palabra) as? String
                
                if clase != nil{
                    if clase == "TG "{
                        palabrasToni += 1
                    }
                    else if clase == "BA "{
                        return false
                    }
                } else {
                    return false
                }
            }
        } else {
            print("ERROR Tweet Vacio o no tiene espacios para separarlo")
        }
        
        
        if palabrasToni == arrayPalabras.count {
            result = true
        }
        
        return result
    }
//MARK: - Es de Blanca Con Palabras Nuevas
    func tweetPurosDeBlancaConPalabrasNuevas(tweet: String) -> Bool{
        //Variables
        let arrayPalabras = tweet.componentsSeparatedByString(" ")
        var result: Bool = false
        var palabrasBlanca = 0
        
        //Procedimiento
        if arrayPalabras.count != 0{
            for i in 0 ..< arrayPalabras.count{
                
                let palabra = arrayPalabras[i]
                let clase: String? = hashClase.objectForKey(palabra) as? String
                
                if clase != nil{
                    if clase == "TG "{
                        return false
                    }
                    else if clase == "BA "{
                        palabrasBlanca += 1
                    }
                } else {
                    //Palabras Neutras
                }
            }
        } else {
            print("ERROR Tweet Vacio o no tiene espacios para separarlo")
        }
        
        
        if palabrasBlanca == arrayPalabras.count {
            result = false
        } else {
            result = true
        }
        
        return result
    }
//MARK: - Es de Toni Con Palabras Nuevas
    func tweetPurosDeToniConPalabrasNuevas(tweet: String) -> Bool{
        //Variables
        let arrayPalabras = tweet.componentsSeparatedByString(" ")
        var result: Bool = false
        var palabrasToni = 0
        
        //Procedimiento
        if arrayPalabras.count != 0{
            for i in 0 ..< arrayPalabras.count{
                
                let palabra = arrayPalabras[i]
                let clase: String? = hashClase.objectForKey(palabra) as? String
                
                if clase != nil{
                    if clase == "TG "{
                        palabrasToni += 1
                    }
                    else if clase == "BA "{
                        return false
                    }
                } else {
                    //Palabras Neutras
                }
            }
        } else {
            print("ERROR Tweet Vacio o no tiene espacios para separarlo")
        }
        
        
        if palabrasToni == arrayPalabras.count {
            result = false
        } else {
            result = true
        }
        
        return result
    }
    
    func getTweet() -> String{
        //LEEMOS TWEET
        tweetLeido = searchBar.text!
        print("tweetLeido: \(tweetLeido)")
        
        //PASAMOS A MINUSCULAS #suavizado
        return tweetLeido.lowercaseString
    }
    func principal(){
        let tweet = getTweet()
        //Si el TWEET tiene palabras que no estan en el CORPUS
        if tweetNoPerteneceANingunCandidato(tweet){
            print("TWEET CONTIENE PALABRAS QUE NO ESTÁN EN EL CORPUS Y NO TIENEN NADA QUE VER CON LA TEMATICA DE LOS CANDIDATOS")
        }
        
        else if tweetTieneDeAmbos(tweet){
            print("El TWEET HABLA DE AMBOS CANDIDATOS, ES UN TWEET NEUTRO")
        }
        
        else if tweetExclusivamenteDeToni(tweet){
            let arrayProbabilidadesTweetSuavizadas = suavizadoToni(tweet)
            print(arrayProbabilidadesTweetSuavizadas)
        }
            
        else if tweetExclusivamenteDeBlanca(tweet){
            let arrayProbabilidadesTweetSuavizadas = suavizadoBlanca(tweet)
            print(arrayProbabilidadesTweetSuavizadas)
            
            let sera = multiplicar(arrayProbabilidadesTweetSuavizadas, tam: arrayProbabilidadesTweetSuavizadas.count)
            print(sera)
        }
        else if tweetPurosDeBlancaConPalabrasNuevas(tweet){
            let arrProbTweeSuaviNew = suavizadoBlancaNuevasPalabras(tweet)
            print(arrProbTweeSuaviNew)
            
            let sera = multiplicar(arrProbTweeSuaviNew, tam: arrProbTweeSuaviNew.count)
            print(sera)
        }
        else if tweetPurosDeToniConPalabrasNuevas(tweet){
            let arrProbTweeSuaviNew = suavizadoToniNuevasPalabras(tweet)
            print(arrProbTweeSuaviNew)
            
            let sera = multiplicar(arrProbTweeSuaviNew, tam: arrProbTweeSuaviNew.count)
            print(sera)
        } else {
            print("ERROR al parecer el Tweet no pertenece a NINGUNA clase")
        }

    }
    
    func getTotalPalabrasBA() -> Int{
        return TOTALPALABRAS_BA
    }
    func getTotalPalabrasTG() -> Int{
        return TOTALPALABRAS_TG
    }
    func updateTotalPalabrasBA(new: Int){
        TOTALPALABRAS_BA = new
    }
    func updateTotalPalbrasTG(new: Int){
        TOTALPALABRAS_TG = new
    }
    
//    int multiplicar (int vec [], int tam)
//    {
//    if (tam == 0)
//    return (vec [0]);
//    return (vec [tam] * multiplicar (vec, tam - 1));
//    }

    func multiplicar(vec: [Float], tam: Int) -> Float{
        
        if tam == 0{
            return (vec[0])
        } else {
            return (vec[tam-1] * multiplicar(vec, tam: tam-1))
        }
    }
    
    
    
    
    
    
    
    
//FIN
}

