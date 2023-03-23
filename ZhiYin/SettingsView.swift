//
//  SettingsView.swift
//  BuZhiYin
//
//  Created by W-Mai on 2023/1/15.
//

import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    @AppStorage("AutoReverse") private var autoReverse = true
    @AppStorage("SpeedProportional") private var speedProportional = true
    @AppStorage("CurrentImageSetString") private var currentImageSet: String?
    @AppStorage("ThemeMode") private var themeMode = 0
    @AppStorage("PlaySpeed") private var playSpeed = 0.5
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ZhiyinEntity.id, ascending: true)],
        animation: .easeInOut)
    private var items: FetchedResults<ZhiyinEntity>
    
    @State private var pop = false
    
    var body: some View {
        TabView {

// MARK: TAB 1 鸡础设置
            VStack {
                ScrollViewReader { scrollView in
                    ScrollView(showsIndicators: false) {
                        VStack {
                            ForEach(items) { item in
                                let sizeScale = currentImageSet == item.id?.uuidString ? 1.5 : 1
                                
                                HStack {
                                    🐔View(entity: item, factor: currentImageSet == item.id?.uuidString ? 0.1 : 0.5).frame(
                                        width: 30 * sizeScale,
                                        height: 30 * sizeScale
                                    )
                                    .cornerRadius(8).animation(.none)
                                    Text(item.name!)
                                    Spacer()
                                    
                                    if currentImageSet == item.id?.uuidString {
                                        EditButtonWithPopover(isPresented: $pop) {
                                            Edit🐔View(item: item)
                                        }
                                    }
                                }
                                .padding(4)
                                .background(Color.secondary.colorInvert())
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                )
                                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(currentImageSet == item.id?.uuidString
                                            ? Color.accentColor
                                            : Color.clear, lineWidth: 2)
                                )
                                .frame(height: 32 * sizeScale)
                                .scaleEffect(currentImageSet == item.id?.uuidString ? 1 : 0.86)
                                .onTapGesture {
                                    currentImageSet = item.id?.uuidString
                                }.id(item.id!.uuidString)
                            }
                            .onChange(of: currentImageSet) { newValue in
                                withAnimation {
                                    scrollView.scrollTo(currentImageSet, anchor: .center)
                                }
                            }
                            
                            // 添加新的只因
                            if items.count == 0 {
                                Button {
                                    _ = PersistenceController.fillDefaultContent(context: viewContext)
                                    _ = PersistenceController.save(context: viewContext)
                                    currentImageSet = "EF2FA09B-20C4-4078-84AD-6879DF5D2DC5"
                                } label: {
                                    HStack {
                                        Label("添加默认小🐔们！！", systemImage: "plus.square")
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .padding(8)
                                    .background(Color.accentColor)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    )
                                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.accentColor)
                                    )
                                }.buttonStyle(.plain)
                                Text("或者")
                            }
                            
                            Button {
                                let newZhiyin = PersistenceController.createDefault🐔(context: viewContext)
                                currentImageSet = newZhiyin.id?.uuidString
                                pop = true
                                _ = PersistenceController.save(context: viewContext)
                            } label: {
                                HStack {
                                    Label("+1只🐔！", systemImage: "plus.square.dashed")
                                }
                                .padding(8)
                                .background(Color.secondary.colorInvert())
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                )
                                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.secondary)
                                )
                            }.buttonStyle(.plain)
                        }
                        .padding(10)
                    }
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke( Color.gray.opacity(0.2), lineWidth: 2)
                            .padding(4)
                    ).onAppear {
                        withAnimation {
                            scrollView.scrollTo(currentImageSet, anchor: .center)
                        }
                    }
                }.animation(.spring(response: 0.2))
                
                Form {
                    Picker(selection: $themeMode, label: Text("主\t题")) {
                        Text("明亮").tag(0)
                        Text("暗黑").tag(1)
                        Text("跟随系统").tag(2)
                    }
                    Toggle("自动反转播放", isOn: $autoReverse).toggleStyle(.switch)
                    Toggle("速度正比CPU", isOn: $speedProportional).toggleStyle(.switch)
                    
                    Slider(value: $playSpeed) {
                        Text("只因速")
                    }
                }.padding()
            }
            .padding()
            .frame(width: 300, height: 400)
            .tabItem {Label("鸡础设置", systemImage: "gear")}

// MARK: TAB 2 高只因设置
            Form {
                Form {
                    LaunchAtLogin.Toggle("开🐔自动太美").toggleStyle(.switch)
                }.padding([.horizontal])
            }.padding([.vertical])
                .frame(width: 300)
                .tabItem {Label("高只因设置", systemImage: "gear.circle")}

// MARK: TAB 3 关于
            Form {
                Spacer()
                VStack {
                    Text("🐔🫵🏻\n🌞🈚️")
                        .font(.system(size: 80)).multilineTextAlignment(.center)
                }.onTapGesture {
                    NSWorkspace.shared.open(URL(string:"https://github.com/W-Mai/BuZhiYin")!)
                }.frame(maxWidth: .infinity, minHeight: 200)
                Spacer(minLength: 25)
                FriendLinksView()
            }.padding([.vertical]).frame(width: 300, height: 360)
                .tabItem {Label("关于", systemImage: "info.circle.fill")}
        }
    }
}

struct FriendLinksView: View {
    var body: some View {
        VStack {
            let frientlinks = friendLinks()
            if frientlinks.count > 0 {
                Text("- 更多推荐 -").frame(maxWidth: .infinity).foregroundColor(.gray)
                ScrollView {
                    ForEach(frientlinks) { frientlink in
                        HStack {
                            Image(frientlink.icon).resizable().frame(width: 50, height: 50).cornerRadius(12, antialiased: true).shadow(color: .gray.opacity(0.1), radius: 2)
                            VStack(alignment: .leading) {
                                Text(frientlink.title)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text(frientlink.desc).font(.subheadline).foregroundColor(.gray)
                            }
                            Spacer()
                            Text("查看").padding().foregroundColor(Color.accentColor)
                        }.frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.primary.colorInvert())
                            .cornerRadius(12)
                            .onTapGesture {
                                NSWorkspace.shared.open(frientlink.link)
                            }
                    }
                }
            }
        }.padding([.horizontal])
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct EditButtonWithPopover<Content: View>: View {
    @Binding var isPresented: Bool
    var content: () -> Content
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "square.and.pencil")
                .resizable()
                .foregroundColor(Color.accentColor)
        }.padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: ContentMode.fit)
            .buttonStyle(.plain)
            .popover(isPresented: $isPresented, arrowEdge: Edge.trailing) {
                content()
            }
    }
}

struct Edit🐔View: View {
    @State var item: ZhiyinEntity
    
    private var name:  Binding<String> { Binding { return item.name!        } set: { item.name         = $0 }}
    private var desc:  Binding<String> { Binding { return item.desc!        } set: { item.desc         = $0 }}
    private var light: Binding<Bool>   { Binding { return item.light_invert } set: { item.light_invert = $0 }}
    private var dark:  Binding<Bool>   { Binding { return item.dark_invert  } set: { item.dark_invert  = $0 }}
    
    @State private var isTargeted: Bool = false
    @State private var needDeleted: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        Form {
            HStack {
                Button {
                    debugPrint("click ")
                } label: {
                    🐔View(entity: item, factor: 0.1)
                }
                .buttonStyle(.plain)
                .cornerRadius(24)
                .padding(8)
                .background(
                    ZStack {
                        Image(systemName: "plus")
                        RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(lineWidth: 4)
                    }.foregroundColor(.accentColor)
                )
                .frame(width: 128, height: 128)
                .onDrop(of: [.gif], isTargeted: $isTargeted) { providers in
                    debugPrint(providers)
                    // 只要第一只
                    guard let provider = providers.first else {
                        return false
                    }
                    
                    provider.loadDataRepresentation(forTypeIdentifier: kUTTypeGIF as String) { data, error in
                        if let data = data {
                            debugPrint(data)
                            let _ = item.setGIF(data: data)
                        } else if let error = error {
                            debugPrint(error.localizedDescription)
                        }
                    }
                    
                    return true
                }
                
                VStack {
                    Form {
                        Label(item.id!.uuidString, systemImage: "number.square")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                        
                        TextField("名字", text: name)
                        TextField("描述", text: desc)
                        Toggle("亮色反转", isOn: light).toggleStyle(.switch)
                        Toggle("暗色反转", isOn: dark).toggleStyle(.switch)
                    }.padding()
                    HStack {
                        Spacer()
                        Button {
                            needDeleted = true
                        } label: {
                            Label("删掉我呗😭", systemImage: "trash").foregroundColor(.red)
                        }.popover(isPresented: $needDeleted) {
                            HStack {
                                Button {
                                    viewContext.delete(item)
                                } label: {
                                    Image(systemName: "arrowshape.right.fill")
                                    Label("啊啊啊！再点我一下就真的删掉了啊喂！！", systemImage: "trash").foregroundColor(.red)
                                    Image(systemName: "arrowshape.left.fill")
                                }.padding().buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onDisappear {
            item.save()
        }
    }
}
