//
//  APIViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/06/07.
//
import Foundation
import RxSwift
import RxCocoa
import Alamofire

// API 통신을 위한 viewModel
struct APIViewModel {
    let disposeBag = DisposeBag()
    
    // viewModel -> viewModel
    let beforeTranslated = PublishSubject<RequestMessage>()
    let afterTranslated = PublishSubject<Result>()
    
    init() {
        beforeTranslated
            .subscribe(onNext: { [self] parameters in
                var headers: HTTPHeaders = [:]
                for (key, value) in APIConstants.shared.values {
                    headers.add(name: key, value: value)
                }
                AF.request(APIConstants.shared.requestURL,
                           method: .post,
                           parameters: parameters,
                           encoder: JSONParameterEncoder.default,
                           headers: headers
                )
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseDecodable(of: ResponseMessage.self) { [self] response in
                    switch response.result {
                    case let .success(responseMessage):
                        let message = responseMessage.message.result
                        self.afterTranslated.onNext(message)
                    case let .failure(error):
                        //TOBE: error alert
                        print("\(error)")
                    }

                }
            })
            .disposed(by: disposeBag)
   
    }

}
