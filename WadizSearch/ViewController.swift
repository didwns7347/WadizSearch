//
//  ViewController.swift
//  WadizSearch
//

import UIKit
import SafariServices


class ViewController: UIViewController {
    @IBOutlet weak var storeBtn: UIButton!
    @IBOutlet weak var fundingBtn: UIButton!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var resultList:[Product]=[]
    var makeTableList:[Product]=[]
    //var lodingService:LoadingService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.resultList = []
        
        let nibName = UINib(nibName: "serchResultViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "SearchResultCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.storeBtn.isHidden = true
        self.allBtn.isHidden = true
        self.fundingBtn.isHidden = true
        
    }

    func openSFSafariView(_ targetURL: String) {
        guard let url = URL(string: targetURL) else { return }
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .automatic
        present(safariViewController, animated: true, completion: nil)
    }
    
    @IBAction func storeBtnTapped(_ sender: Any) {
        self.makeTableList = self.resultList.filter{$0.type == Product.ProductType.store}
        self.tableView.reloadData()
    }
    @IBAction func funddingBtnTapped(_ sender: Any) {
        self.makeTableList = self.resultList.filter{$0.type == Product.ProductType.fundingOpen}
        self.tableView.reloadData()
    }
    @IBAction func allBtnTapped(_ sender: Any) {
        self.makeTableList = self.resultList
        self.tableView.reloadData()
    }
    
    
    
}
extension ViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.makeTableList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? serchResultViewCell else{return UITableViewCell()}
        cell.titleLabel.numberOfLines = 0
        cell.tagLabel.numberOfLines = 0
        cell.titleLabel.isUserInteractionEnabled = true
        cell.resultImage.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.linkTap))
        
        if let product = self.makeTableList[indexPath.row] as? Product{
            cell.titleLabel.text = product.title
            cell.categoryLabel.text = product.category?.name ?? ""
            cell.tagLabel.text = product.additionalInfo ?? ""
            cell.priceLabel.text = String(self.resultList[indexPath.row].price ?? 0)+"원"
            var imgloader = ImageLoader(url: product.photoURL ?? "")
            imgloader.load { result in
                switch result{
                case .success(let img):
                    DispatchQueue.main.async {
                        cell.resultImage.image = img
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        cell.resultImage.image = UIImage(systemName: "Stop")
                    }
                    
                }
            }
            
            
            return cell
        }
        
    }
    @IBAction func linkTap(sender:UITapGestureRecognizer){
        
    }
    
}

//서치바 델리게이트 구현부
extension ViewController: UISearchBarDelegate{
    private func dissmissKeyboard(){
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dissmissKeyboard()
        self.fundingBtn.isHidden = false
        self.allBtn.isHidden = false
        self.storeBtn.isHidden = false
        
        LoadingService.showLoading()
        if let keyword = self.searchBar.text{
            API.search(keyword: keyword)
                .get { result in
                    LoadingService.hideLoading()
                    switch result{
                    case .success(let data):
                        print(data)
                        print(type(of: data))
                        if data.statusCode == 200{
                            print(data.body)
                            print(type(of:data.body))
                            self.resultList=data.body.list
                            self.makeTableList = self.resultList
                            self.tableView.reloadData()
                        }
                        else{
                            
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
        }
    }
}
