module GossipHelper
  def gossip_active?
    InchCI::Gossip::GOSSIP_ACTIVE
  end

  def gossip_server
    return unless gossip_active?
    InchCI::Gossip::GOSSIP_HOST
  end

  def gossip_room
    return unless gossip_active?
    if @project
      "projects:#{@project.uid}"
    else
      @gossip_room # "projects:lobby"
    end
  end
end
