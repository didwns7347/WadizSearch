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
    //이미지로딩 케시
    var imgCache : Dictionary<String,UIImage> = [:]
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.allowsSelection = false
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
        var product = makeTableList[indexPath.row]
        cell.titleLabel.text = product.title
        cell.categoryLabel.text = product.category?.name ?? ""
        cell.tagLabel.text = product.additionalInfo ?? ""
        cell.priceLabel.text = String(product.price ?? 0)+"원"
        if (self.imgCache[product.photoURL ?? ""] != nil){
            cell.resultImage.image = self.imgCache[product.photoURL ?? ""]
        }else{
            let imgloader = ImageLoader(url: product.photoURL ?? "")
            
            imgloader.load { result in
                switch result{
                case .success(let img):
                    DispatchQueue.main.async {
                        cell.resultImage.image = img
                        self.imgCache[product.photoURL ?? ""] = img
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        cell.resultImage.image = UIImage(systemName: "Stop")
                    }
                    
                    
                }
            }
        }
        cell.showLinkAction = { [unowned self] in
            let product = self.makeTableList[indexPath.row]
            self.openSFSafariView(product.landingURL)
            
        }
        
        
        return cell
        
        
    }
    @IBAction func linkImgTapped(sender:UITapGestureRecognizer){
        guard let img = sender as? UIImageView else {return}
        print(img.tag)
    
        
    }
    @IBAction func linkTitleTapped(sender:UITapGestureRecognizer){
        guard let title = sender as? UILabel else {return}
        print(title.tag)
        
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
