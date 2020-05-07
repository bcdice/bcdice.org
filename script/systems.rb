require 'net/https'
require 'json'

API = 'bcdice.herokuapp.com'

# Fetch system names

def fetch_systems
  json = Net::HTTP.get(API, '/v1/names')
  JSON.parse(json)['names'].sort_by {|s| s['sort_key']}
end

def fetch_version
  json = Net::HTTP.get(API, '/v1/version')
  JSON.parse(json)['bcdice']
end

systems = fetch_systems()

# Grouping
def group(sort_key)
  %w[あ か さ た な は ま や ら わ 国].reverse.each do |row|
    if sort_key[0] >= row
      return row
    end
  end

  return nil
end

grouped = systems.group_by{|s| group(s['sort_key'])}

if grouped[nil].length > 1
  warn '標準ダイスボット以外のものが nil に分類されました'
end

grouped['International'] = grouped['国']

grouped.delete(nil)
grouped.delete('国')

out = {
  version: fetch_version(),
  systems: grouped,
}

path = File.join(__dir__, '../_data/systems.json')
File.write(path, JSON.pretty_generate(out))
puts "Updated _data/systems.json"
