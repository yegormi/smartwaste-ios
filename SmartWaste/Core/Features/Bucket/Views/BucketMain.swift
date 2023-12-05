//
//  MapMain.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import SwiftUI
import ComposableArchitecture
import PartialSheet

struct BucketMainView: View {
    let store: StoreOf<BucketMain>
        
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Text("Bucket")
                    .font(.system(size: 32, weight: .semibold))
                Spacer()
                VStack(spacing: 15) {
                    Button {
                        viewStore.send(.sheetPresented)
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.green, lineWidth: 2)
                            .frame(height: 60)
                            .overlay(
                                Text("Add item")
                                    .foregroundStyle(Color.green)
                                    .font(.system(size: 24))
                            )
                    }
                    .scaleButton()
                    
                    Button {
                        
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green)
                            .frame(height: 60)
                            .overlay(
                                Text("Show recycle points")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 20))
                            )
                    }
                    .scaleButton()
                }
            }
            .padding(30)
            .partialSheet(isPresented: viewStore.binding(
                get: \.isSheetPresented,
                send: BucketMain.Action.sheetPresented
            )) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Add item")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.primary)
                        .padding(.vertical, 10)
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .frame(height: 50)
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 20))
                    }
                    HStack(spacing: 0) {
                        Button {
                        } label: {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.black, lineWidth: 1)
                                .foregroundStyle(Color.clear)
                                .overlay (
                                    Text("-")
                                        .foregroundStyle(Color.primary)
                                        .font(.system(size: 28))
                                )
                        }
                        .frame(width: 40, height: 40)
                        Text("1")
                            .font(.system(size: 40))
                            .padding(.horizontal, 20)
                        Button {
                        } label: {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.black, lineWidth: 1)
                                .foregroundStyle(Color.clear)
                                .overlay (
                                    Text("+")
                                        .foregroundStyle(Color.primary)
                                        .font(.system(size: 28))
                                )
                        }
                        .frame(width: 40, height: 40)
                    }
                    .padding(.bottom, 65)
                    Button {
                        
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.clear)
                            .frame(height: 60)
                            .overlay(
                                Text("Add")
                                    .foregroundStyle(Color.primary)
                                    .font(.system(size: 20))
                            )
                    }
                    .scaleButton()
                    
                    Button {
                        viewStore.send(.sheetPresented)
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red)
                            .frame(height: 60)
                            .overlay(
                                Text("Cancel")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 20))
                            )
                    }
                    .scaleButton()
                }
                .padding(.horizontal, 30)
            }
        }
        
    }
}

@Reducer
struct BucketMain: Reducer {
    
    struct State: Equatable {
        var isSheetPresented = false
    }
    
    enum Action: Equatable {
        case sheetPresented
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .sheetPresented:
                state.isSheetPresented.toggle()
                return .none
            }
        }
    }
}
