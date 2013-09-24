class RequestsController < ApplicationController
  require 'net/http'

  def index
    #@requests = Request.all
    @requests = Request.order("updated_at DESC")
    @stitches = Hash.new

    @requests.each do |request|
      @stitches["#{request.id}"] = get_stitch(request.stitch_id)
    end
  end

  def show
    @request = Request.find(params[:id])

    # Hash previously parsed from JSON response
    @stitch = get_stitch(@request.stitch_id)
  end

  def new
    @request = Request.new
  end

  def create
    @request = Request.new(params[:request])

    # Try to create a remote Stitch request
    @request.stitch_id = request_stitch(params[:stitch])

    if @request.save
      flash[:success] = "Stitch created!"

     # Send to home (where the feed should be, for Admins)
      redirect_to request_path(@request.id)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @request = Request.find(params[:id])
    if @request.update_attributes(stitch_id: remix_stitch(@request.stitch_id))
      flash[:success] = "You've requested a REMIX of this Stitch! Coming right up..."

      redirect_to request_path(@request.id)
    else
      redirect_to request_path(@request.id)
    end
  end

  def destroy
  end

  private

  def request_stitch(stitch)
    url = URI.parse(get_api_url + '.json')
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data(
        {
          "api_key" => get_api_key,
          "stitch[name]" => stitch[:name],
          "stitch[description]" => stitch[:description],
          "stitch[notes]" => stitch[:notes]
        }
    )
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    JSON(res.body)["stitch"]["id"]
  end

  def get_stitch(stitch_id)
    params = {
        api_key: get_api_key
    }

    uri = URI.parse(get_api_url + "/#{stitch_id}.json")
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)

    # JSON
    parse_stitch(response.body)
  end

  def remix_stitch(stitch_id)
    # 1.) Fetch remote stitch,
    # 2.) Update remote stitch status to "rejected",
    # 3.) Request new stitch with duplicate params
    # 4.) Return 'id' of new remote stitch for updating local request "stitch_id"
    stitch = get_stitch(stitch_id)

    url = URI.parse(get_api_url + "/#{stitch_id}.json")
    req = Net::HTTP::Put.new(url.path)
    req.set_form_data(
        {
            "api_key" => get_api_key,
            "stitch[rejected]" => "1"
        }
    )
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }

    new_stitch = { name: stitch['name'], notes: stitch['notes'], description: stitch['description'] }
    request_stitch(new_stitch)
  end

  def get_api_key
    # stitchdoug
    #'27BiwVie8kRCH1BwNwprkg'

    # stitchdoug (localhost)
    # '3LCWrhOtSgpYqoaaVZPt2A'

    # stitchdustin
    #'ymTaxlSSTRvKGqNZ-ZHf8A'

    # mindjet
    'LqoHKveoOUAraMj-KeCF2g'
  end

  def get_api_url
    api_url = 'http://evening-savannah-3101.herokuapp.com/stitches'
  end

end
