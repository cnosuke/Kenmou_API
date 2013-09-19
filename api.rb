# coding:utf-8
require "open-uri"
require "kconv"
require "json"

module News
  #ニュー速(嫌儲)勢いAPI
  class Ikioi

    def initialize(board_name = "poverty")
      url = "http://2ch-ranking.net/ranking.json?board=#{board_name}&callback=callback"
      raw_ikioi_str = Kconv.toutf8(open(url).read)
      ikioi_str = raw_ikioi_str.gsub(/^callback\(/,"").gsub(/\);$/,"")
      @ikioi_arr = JSON.parse(ikioi_str)
    end

    #人気順に任意の個数( < 100)のdat番号の配列を返す
    def datfiles(num = 10)
      dat_files = []
      num.times {|i|
        url = @ikioi_arr[i]["url"]
        thread_id = url.split("/").last
        dat_files << thread_id + ".dat"
      }
      return dat_files
    end

    #任意の順位( < 100)のデータを返す
    def details(num = 1)
      #入ってるデータ：rank,updown,board_name,board,url,title,res,ikioi
      return @ikioi_arr[num - 1]
    end

  end


  #ニュー速(嫌儲)スレッド用API
  class Thread

    def initialize(dat)
      @dat = dat
      @title = get_title
      @thread_data = thread_data_to_array #number,name,date,textの辞書
      @res_count = @thread_data.count #レス数
    end

    def title
      return @title
    end

    #指定した番号のレスを抽出
    def res(num = 1)
      return @thread_data[num -1]
    end

    #ID抽出
    def find_id(id = "sample")
      result = []
      @thread_data.each do |res_data|
        if res_data["date"].include?(id)
          result << res_data
        end
      end
      return result
    end

    #指定した番号へのレスを全て抽出
    def to_res(num =1)
      result = []
      @thread_data.each do |res_data|
        if res_data["text"].include?("&gt;&gt;#{num}</a>")
          result << res_data
        end
      end
      return result
    end

    private
    #スレッドを整形
    def thread_data_to_array
      url = "http://engawa.2ch.net/poverty/dat/#{@dat}"
      raw_thread = Kconv.toutf8(open(url).read).strip
      result = []
      res_number = 1
      raw_thread.split("<>").each_slice(4).with_index(1) do |res_data,i|
        result << {
          "number" => i,
          "name" => res_data[0].strip,
          "date" => res_data[2],
          "text" => res_data[3].strip
        }
      end
      return result
    end

    #subject.txtからスレタイ取得
    def get_title
      subject_url = "http://engawa.2ch.net/poverty/subject.txt"
      raw_subject = Kconv.toutf8(open(subject_url).read).strip
      raw_subject.each_line do |data|
        if data.include?(@dat)
          return data.split("<>")[1].chomp.sub(/\([0-9]+\)$/,"").strip
        end
      end
    end

  end

end


