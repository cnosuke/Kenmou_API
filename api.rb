# coding:utf-8
require "open-uri"
require "kconv"
require "json"

module News
  class Ikioi
    def initialize(board_name = "poverty")
      url = "http://2ch-ranking.net/ranking.json?board=#{board_name}&callback=callback"
      raw_ikioi_str = Kconv.toutf8(open(url).read)
      ikioi_str = raw_ikioi_str.gsub(/^callback\(/,"").gsub(/\);$/,"")
      @ikioi_arr = JSON.parse(ikioi_str)
    end

    def datfile(num = 1)
      # example:  News.datfile => "1281073407.dat"
      if 0 < num && num <= 100
        url = @ikioi_arr[num -1]["url"]
        thread_id = url.split("/").last
        dat_file = thread_id + ".dat"
        return dat_file
      else
        false
      end
    end

    def details(num = 1)
      #   example:
      #   News.details =>
      #   {"rank"=>"1",
      #   "updown"=>"new",
      #   "url"=>"engawa.2ch.net/poverty/1381073407/",
      #   "title"=>"【速報】アニメDVD・BDの売り上げを見守るスレ13917 ",
      #   "res"=>"999",
      #   "ikioi"=>"31246"}
      if 0 < num && num <= 100
        return @ikioi_arr[num - 1]
      else
        return false
      end
    end

  end


  class Thread

    attr_reader :title, :res_count
    def initialize(dat)
      @dat = dat
      @title = get_title
      @thread_data = thread_data_to_array 
      @res_count = @thread_data.count 
    end

    def res(num = 1)
      # example News::Thread.res =>
      #  {"number"=>1,
      #   "name"=>"番組の途中ですがアフィサイトへの天才は禁止です",
      #   "date"=>"2013/10/07(月) 00:30:07.81 ID:P0Y/yhN+0 BE:1063741853-2BP(1260)",
      #   "text"=>"本文"}
      return @thread_data[num -1]
    end

    def find_id(id = "sample")
      result = []
      @thread_data.each do |res_data|
        if res_data["date"].include?(id)
          result << res_data
        end
      end
      return result
    end

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


