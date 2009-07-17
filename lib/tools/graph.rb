# Our first twitter tool: Graphing connections from the first user to the second.
# This will check the first 3 degrees for links, and return a hash of connections
# found in each degree.
# Once any degree has a connection in it, additional degrees are not checked.

class Tootils
  class Graph

    attr_accessor :tootils, :root, :link

    def initialize(tootils, root_user, linked_user)
      @tootils  = tootils
      @root     = root_user
      @link     = linked_user
    end

    def process
      root_id = tootils.info(root)['id']
      root_friends = tootils.friends(root)
      link_id = tootils.info(link)['id']
      link_followers = tootils.followers(link)
      # Start assuming there are no connections
      graph = { 1 => [], 2 => [], 3 => [] }
    
      if link_followers.include?(root_id)
        graph[1] = [[root_id, link_id]]
      end
    
      return graph unless graph[1].empty?
    
      # Check second degree: Are there friends of root who follow link? 
      # Get an array of all connections.
      for friend in (root_friends & link_followers)
        graph[2] << [root_id, friend, link_id]
      end
      return graph unless graph[2].empty?
    
      # Check the 3rd degree: This is the real API hit.
      # We need to check friends of friends, or the followers of followers,
      # which ever is fewer
      if root_friends.length < link_followers.length
        for friend in root_friends
          friends_of_friend = tootils.friends(friend)
          deg3 = friends_of_friend & link_followers
          # Add a connection for each friend of a friend who is a follower of link
          for fof in deg3
            graph[3] << [root_id, friend, fof, link_id]
          end
        end
      else
        for follower in link_followers
          followers_of_follower = tootils.followers(follower)
          deg3 = root_friends & followers_of_follower
          # Add a connection for each follower of a follower who is a friend of root
          for fof in deg3
            graph[3] << [root_id, fof, follower, link_id]
          end rescue pp "Can't get followers for #{follower}: #{tootils.info(follower)}"
        end
      end
      return graph
    end
  end
end