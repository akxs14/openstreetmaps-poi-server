

class POIManager

  @@R = 6371e3

  private

  def toRads degs
    degs / 360 * 2 * Math.PI
  end

  def haversine lon1_deg, lat1_deg, lon2_deg, lat2_deg
    lat1 = toRads(lat1_deg)
    lat2 = toRads(lat2_deg)
    dlat = toRads(lat2_deg - lat1_deg)
    dlon = toRads(lon2_deg - lon1_deg)

    a = Math.sin(dlat / 2) * Math.sin(dlat / 2) + 
        Math.cos(lat1) * Math.cos(lat2) * 
        Math.sin(dlon / 2) * Math.sin(dlon / 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    R * c
  end

end