import UIKit

class PokemonListViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var pokemon: [PokemonListResult] = []
    var searchResults: [PokemonListResult] = []
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // implementation
        searchResults.removeAll()
        
        if searchText.count != 0 {
            for one in pokemon {
                if one.name.contains(searchText.lowercased()) {
                    searchResults.append(one)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar!.delegate = self
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchResults.count == 0 {
            return pokemon.count
        }
        else {
            return searchResults.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        
        if searchResults.count == 0 {
            cell.textLabel?.text = capitalize(text: pokemon[indexPath.row].name)
        }
        else {
            cell.textLabel?.text = capitalize(text: searchResults[indexPath.row].name)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPokemonSegue",
                let destination = segue.destination as? PokemonViewController,
                let index = tableView.indexPathForSelectedRow?.row {
            if searchResults.count == 0 {
                destination.url = pokemon[index].url
                destination.name = pokemon[index].name
            }
            else {
                destination.url = searchResults[index].url
                destination.name = searchResults[index].name
            }
        }
    }
}
