import UIKit
import SceneKit
import Accelerate
import CoreData

class ProteinViewController: UIViewController {
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    var molecule: Molecules!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupScene()
        setupCamera()
        spawnAtom()
        
        
        let pdbFile = "ATOM      1  CHA HEM A   1       2.748 -19.531  39.896  1.00 10.00           C\nATOM      2  CHB HEM A   1       3.258 -17.744  35.477  1.00 10.00           C"
        
        deleteAllEntities("Atoms")
        deleteAllEntities("Molecules")
        createMolecule(moleculePdb: pdbFile)
        fetchAll()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView() {
        scnView = (self.view as! SCNView)
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnView.showsStatistics = true
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 60)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func spawnAtom() {
        var geometry: SCNGeometry
        var geometry2: SCNGeometry
        let pos1 = simd_float3(x:2, y:5, z:6)
        let pos2 = simd_float3(x:10, y:1, z:3)
        let yAxis = simd_float3(x:0, y:1, z:0)
        let diff = pos2 - pos1
        let norm = simd_normalize(diff)
        let dot = simd_dot(yAxis, norm)
        
        geometry = SCNSphere(radius: 0.6)
        geometry2 = SCNCylinder(radius: 0.3, height: 1)
        
        let geometryNode1 = SCNNode(geometry: geometry)
        let geometryNode2 = SCNNode(geometry: geometry)
        let geometryNode3 = SCNNode(geometry: geometry2)
        
        if (abs(dot) < 0.999999)
        {
            let cross = simd_cross(yAxis, diff)
            let quaternion = simd_quatf(vector: simd_float4(x: cross.x, y: cross.y, z: cross.z, w: 1 + dot))
            geometryNode3.simdOrientation = simd_normalize(quaternion)
        }
        
        geometryNode1.simdPosition = pos1
        geometryNode2.simdPosition = pos2
        geometryNode3.simdPosition = diff / 2 + pos1
        geometryNode3.simdScale = simd_float3(x: 1, y: simd_length(diff), z: 1)
        
        scnScene.rootNode.addChildNode(geometryNode1)
        scnScene.rootNode.addChildNode(geometryNode2)
        scnScene.rootNode.addChildNode(geometryNode3)
    }
    
    func createAtom(atomPdb: String, molecule : Molecules){
        let atom = Atoms(context: context)
        let splitAtomLine = atomPdb.split(separator: " ", omittingEmptySubsequences: true)

        atom.name = String(splitAtomLine[11])
        atom.atom_Id = String(splitAtomLine[2])
        atom.coor_X = Float(String(splitAtomLine[6]))!
        atom.coor_Y = Float(String(splitAtomLine[7]))!
        atom.coor_Z = Float(String(splitAtomLine[8]))!
        
        molecule.addToAtom(atom)
    }
    
    func createMolecule(moleculePdb: String){
        let molecule = Molecules(context: context)
        molecule.name = "proteineDeOuf"
        molecule.ligand_Id = "jlkjlkj"
        
        let pdbLines = moleculePdb.split(separator: "\n", omittingEmptySubsequences: true)
        var lineTmp: Array<Substring>!
        
        for line in pdbLines{
            lineTmp = line.split(separator: " ",omittingEmptySubsequences: true)

            if (lineTmp[0] == "ATOM"){
                createAtom(atomPdb: String(describing: line), molecule: molecule)
            }
//            else if (lineTmp[0] == "CONECT"){
//            }
            else{
                print("End of file\n")
            }
        }
        
        do {
            try context.save()
            print("bien sauvegardé")
        } catch let error{
            print(error)
        }
    }
    
    func fetchAll(){
        let request: NSFetchRequest<Molecules> = Molecules.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        guard let molecules = try? context.fetch(request) else {
            print("Error fetching molecules")
            return
        }
        
        for molecule in molecules {
            print(molecule.name)
        
            for atom in molecule.atom as! Set<Atoms> {
                print(atom.atom_Id)
            }
        }
    }
}


//    func createLink(newLink: Array<Substring>){
//        /*
//            newLink[1] est l atom de ref, les suivant sont ses connections.
//            si l'id des suivant est superieur a celui de ref alors ont inscrit une nouvelle connection.
//            sinon elle a logiquement deja été inscrite
//        */
//
//        let firstId = Int(newLink[1])!
//        for secondId in 2..<newLink.count{
//            if (firstId < Int(secondId)){
//                molecule.links.append((firstId, Int(secondId)))
//            }
//        }
//    }
//
//    func AddOneSphere(moleculePdb: String){
//
//        var geometry: SCNGeometry
//
//        geometry = SCNSphere(radius: 0.6)
//        let geometryNode1 = SCNNode(geometry: geometry)
//        geometryNode1.position = SCNVector3(x:2, y:5, z:6)
//        scnScene.rootNode.addChildNode(geometryNode1)
//
//    }


