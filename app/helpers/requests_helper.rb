module RequestsHelper

  def parse_stitch(stitch)
    # Parse JSON into usable Ruby Hash
    parsed = JSON(stitch)["stitch"]

    if parsed["video"].nil?
       parsed["video"] = {}
       parsed["video"]["h264"] = {}
       parsed["video"]["h264"]["status"] = "processing"
    end

    parsed
  end

  def get_status(rejected, status)
    # Generate a <span> showing a status label
    if rejected == true
      content_tag(:span, "Rejected", :class => "label label-important center")
    elsif rejected == false && status == "success"
      content_tag(:span, "Complete", :class => "label label-success center")
    elsif rejected == false && status == "processing"
      content_tag(:span, "Pending", :class => "label center")
    end
  end
end
