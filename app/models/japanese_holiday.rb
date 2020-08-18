# frozen_string_literal: true

class JapaneseHoliday < ActiveHash::Base
  # NOTE: https://www8.cao.go.jp/chosei/shukujitsu/gaiyou.html の CSV ファイル
  self.data = [
    { id: 1,  date: Date.parse("2020/1/1"),   name: "元日" },
    { id: 2,  date: Date.parse("2020/1/13"),  name: "成人の日" },
    { id: 3,  date: Date.parse("2020/2/11"),  name: "建国記念の日" },
    { id: 4,  date: Date.parse("2020/2/23"),  name: "天皇誕生日" },
    { id: 5,  date: Date.parse("2020/2/24"),  name: "休日" },
    { id: 6,  date: Date.parse("2020/3/20"),  name: "春分の日" },
    { id: 7,  date: Date.parse("2020/4/29"),  name: "昭和の日" },
    { id: 8,  date: Date.parse("2020/5/3"),   name: "憲法記念日" },
    { id: 9,  date: Date.parse("2020/5/4"),   name: "みどりの日" },
    { id: 10, date: Date.parse("2020/5/5"),   name: "こどもの日" },
    { id: 11, date: Date.parse("2020/5/6"),   name: "休日" },
    { id: 12, date: Date.parse("2020/7/23"),  name: "海の日" },
    { id: 13, date: Date.parse("2020/7/24"),  name: "スポーツの日" },
    { id: 14, date: Date.parse("2020/8/10"),  name: "山の日" },
    { id: 15, date: Date.parse("2020/9/21"),  name: "敬老の日" },
    { id: 16, date: Date.parse("2020/9/22"),  name: "秋分の日" },
    { id: 17, date: Date.parse("2020/11/3"),  name: "文化の日" },
    { id: 18, date: Date.parse("2020/11/23"), name: "勤労感謝の日" },
    { id: 19, date: Date.parse("2021/1/1"),   name: "元日" },
    { id: 20, date: Date.parse("2021/1/11"),  name: "成人の日" },
    { id: 21, date: Date.parse("2021/2/11"),  name: "建国記念の日" },
    { id: 22, date: Date.parse("2021/2/23"),  name: "天皇誕生日" },
    { id: 23, date: Date.parse("2021/3/20"),  name: "春分の日" },
    { id: 24, date: Date.parse("2021/4/29"),  name: "昭和の日" },
    { id: 25, date: Date.parse("2021/5/3"),   name: "憲法記念日" },
    { id: 26, date: Date.parse("2021/5/4"),   name: "みどりの日" },
    { id: 27, date: Date.parse("2021/5/5"),   name: "こどもの日" },
    { id: 28, date: Date.parse("2021/7/19"),  name: "海の日" },
    { id: 29, date: Date.parse("2021/8/11"),  name: "山の日" },
    { id: 30, date: Date.parse("2021/9/20"),  name: "敬老の日" },
    { id: 31, date: Date.parse("2021/9/23"),  name: "秋分の日" },
    { id: 32, date: Date.parse("2021/10/11"), name: "スポーツの日" },
    { id: 33, date: Date.parse("2021/11/3"),  name: "文化の日" },
    { id: 34, date: Date.parse("2021/11/23"), name: "勤労感謝の日" }
  ]
end
