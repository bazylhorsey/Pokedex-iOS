import UIKit

class PokemonViewController: UIViewController {
    var url: String!
    var name: String!

    @IBOutlet var imageView: UIImageView!

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!

    @IBOutlet var catchButton: UIButton!
    
    @IBOutlet var descriptionText: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        
        descriptionText.text = ""
        
        loadPokemon()
        initCatchStatus()
    }
    
    @IBAction func toggleCatch() {
        //
        if UserDefaults.standard.object(forKey: self.name) == nil {
            UserDefaults.standard.set(true, forKey: self.name)
            self.catchButton.setTitle("Release", for: .normal)
            return
        }
        
        UserDefaults.standard.removeObject(forKey: self.name)
        
        self.catchButton.setTitle("Catch", for: .normal)
    }

    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    func initCatchStatus() {
        if UserDefaults.standard.object(forKey: self.name) != nil {
            self.catchButton.setTitle("Release", for: .normal)
        }
    }
    
    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)

                    let urlDescription = "https://pokeapi.co/api/v2/pokemon-species/\(result.id)"
                    URLSession.shared.dataTask(with: URL(string: urlDescription)!) { (data, response, error) in
                                                
                        guard let data = data else {
                            return
                        }
                        
                        do {
                            let result = try JSONDecoder().decode(PokemonSpeciesEntry.self, from: data)
                            DispatchQueue.main.async {
                                for entry in result.flavor_text_entries {
                                    if entry.language.name == "en" {
                                        self.descriptionText.text = entry.flavor_text
                                        break
                                    }
                                }
                            }
                        }
                        catch let error {
                            print(error)
                        }
                    }.resume()
                    
                    if let data = try? Data(contentsOf: URL(string: result.sprites.front_default)!) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.imageView.image = image
                            }
                        }
                    }
                    
                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
}
