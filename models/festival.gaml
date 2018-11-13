/**
* Name: Basic model (prey agents)
* Author:
* Description: First part of the tutorial : Predator Prey
* Tags:
*/

model festival

global {
	int nb_guests <- 10;
	int drunk_threshold <- 5;
	int guest_speed <- 2;
	int guard_speed <- 4;
	
	int thirsty <- 10;
	int hunger <- 10;
	int broke <- 2;
	
	int distance_travelled <- 0;
	
	point info_center<- {50,50};
	point bank_location <- {90,90};
	
	int max_food <- 10;
	int max_drinks <- 10;
	
	list<Shop> ShopList <- [];
	
	Bank theBank;
	
	init {
		create guest number: nb_guests ;
		create InfoCenter number: 1 ;
		create Guard number: 1 ;
		create Shop number: 4;
		create Bank number: 1;
	}
	
	bool challenge1 <- false;
	bool challenge2 <- true;
	
	bool creative1 <- true;
	bool creative2 <- true;
}

species Guard skills: [moving]{
	float size <- 2.0 ;
	rgb color <- #black;
	aspect base {
		draw circle(size) color: color ;
	}
	
	list<guest> targets <- [];
	bool pursue <- false;
	
	reflex kill when: challenge2 and length(self.targets)>0{
		point target <- self.targets[0].location;
		do goto target: target speed: guard_speed;
		
		if( self.location distance_to(target) < 2){
			ask (guest){
				if(length(myself.targets)>0 and self = myself.targets[0]){
					write "Killed!";
					write "Total Distance: " + distance_travelled;
					remove first(myself.targets) from: myself.targets;
					do die;
				}
			}
		}
	}
}

species Bank{
	
	bool initialized <- false;
	
	aspect base {
		draw box(2,2,2) at: bank_location  color: #grey;
	}
	
	reflex initialize when: !self.initialized{
		theBank <- self;
		self.initialized <- true;
	}
}

species Shop{
	bool initialized <- false;
	point location <- {rnd(0,100), rnd(0,100)};
	
	int drinks <- max_drinks;
	int food <- max_food;
	
	aspect base {
		draw box(2,2,2) at: self.location  color: #orange;
	}
	
	reflex initialize when: !self.initialized{
		add self to: ShopList;
		self.initialized <- true;
	}
	
}


species InfoCenter{
	aspect base {
		draw box(2,2,2) at: info_center color: #yellow;
	}
	
	int store <- 1;
	guest badGuest;
	bool report <- false;
	
	reflex callSecurity when: challenge2 and report{
		ask(Guard){
			add myself.badGuest to: self.targets;
			self.pursue <- true;
			write "Pursue!";
			myself.report <- false;
		}
	}
}

species guest skills: [moving]{
	float size <- 1.0 ;
	rgb color <- #green;
	
	bool dancing <- true;
	bool isThirsty <- false;
	bool isHungry <- false;
	bool isBroke <- false;
	
	int thirst_level <- rnd(100,200);
	int hunger_level <- rnd(100,200);
	int money_level <- rnd(5, 20);
	
	int original_thirst <- thirst_level;
	int original_hunger <- hunger_level;
	int original_money <- money_level;
	
	int thirst_dec <- rnd(1,10);
	int hunger_dec <- thirst_dec;
	
	int drunk <- 0;
	
	point target <- info_center;
	
	list<int> memory  <- [];
	Shop target_shop;
	 
		
	aspect base {
		draw circle(size) color: color ;
	}
	
	reflex level_reduction when: self.dancing and !self.isBroke and !self.isThirsty and !self.isHungry{
		self.thirst_level <- self.thirst_level - self.thirst_dec;
		self.hunger_level <- self.hunger_level - self.hunger_dec;
	}
	
	reflex just_print{
		write "hunger: " + self.hunger_level + " thirst: " + self.thirst_level + " money: " + self.money_level;
	}
	
	reflex moneyTrouble when: creative2 and self.money_level < broke{
			self.isBroke <- true;
			self.target <- bank_location;
			self.color <- #purple;
			write "I am broke";
			self.dancing <-false;
			self.isHungry <- false;
			self.isThirsty <-false;
			self.hunger_level <- self.hunger_level + (hunger);
			self.thirst_level <- self.thirst_level + (thirsty);
	}
	
	reflex basic_move when: self.dancing and !self.isBroke{
		
		if thirst_level < thirsty{
			self.color <- #blue;
			write "I am thirsty";
		} 
		
		else if hunger_level < hunger{
			self.color <- #red;
			write "I am hungry";
		}
		
		else {
			do wander;
			write "I am dancing";
		}
		
	}
	
	reflex forget when: challenge1 and self.drunk > drunk_threshold{
		if self.drunk = drunk_threshold + 1{
			write "I forgot Everything!";
			self.drunk <- self.drunk+1;
		}
		self.memory <- [];
	}
	
	
	reflex gotoInfoCenter when: (self.thirst_level < thirsty and !self.isThirsty) or 
									(self.hunger_level < hunger and !self.isHungry)
	{
			self.dancing <- false;
			if challenge1 and length(self.memory) = 4 {
				int store <- self.memory[rnd(3)];
				if store = 1{
					self.target <- ShopList[0].location;
					self.target_shop <- ShopList[0];
				}
				else if store = 2 {
					self.target <- ShopList[1].location;
					self.target_shop <- ShopList[1];
				}
				else if store = 3 {
					self.target <- ShopList[2].location;
					self.target_shop <- ShopList[2];
				}
				else if store = 4 {
					self.target <- ShopList[3].location;
					self.target_shop <- ShopList[3];
				}
				
				if thirst_level < thirsty{
					self.isThirsty <- true;
					self.color <- #blue;
				} else{
					self.isHungry <- true;
					self.color <- #red;
				}
				
			}
			else
			{
				do goto target:info_center speed: guest_speed;
				distance_travelled <- distance_travelled + 1;
				
	//			write "I am thirsty!";
				if( location distance_to(info_center) < 3){
					ask InfoCenter {
						bool new_location <- true;
						if challenge1 and length(myself.memory) > 0{
							int times <- 0;
							self.store <- self.store + 1;
							if self.store > 4{
								self.store <- 1;
							}
							loop i from: 0 to: length(myself.memory) -1 {
								self.store <- self.store + 1;
								if self.store > 4{
									self.store <- 1;
								}	
								if myself.memory[i] = self.store{
									i <- 0;
									times <- times + 1;
									if times > 4{
										new_location <- false;
										break;
									}
								}
							}
						}
						else{
							self.store <- self.store + 1;
							if self.store > 4{
								self.store <- 1;
							}
						}
				
						if challenge1 and new_location{
							add self.store to: myself.memory;
						}
				
						if store = 1{
							myself.target <- ShopList[0].location;
							myself.target_shop <- ShopList[0];
						}
						else if store = 2 {
							myself.target <- ShopList[1].location;
							myself.target_shop <- ShopList[1];
						}
						else if store = 3 {
							myself.target <- ShopList[2].location;
							myself.target_shop <- ShopList[2];
						}
						else if store = 4 {
							myself.target <- ShopList[3].location;
							myself.target_shop <- ShopList[3];
						}
				
				
						if myself.thirst_level < thirsty{
							myself.isThirsty <- true;
							if challenge2 and myself.drunk > drunk_threshold{
								self.badGuest <- myself;
								self.report <- true;
								write "bad guest!";
							}
							myself.color <- #blue;
						}
						
						if myself.hunger_level < hunger{
							myself.isHungry <- true;
							myself.color <- #red;
						}
					}
					
				}
				
			}
			
	}
			
	
	reflex replenish when: self.isThirsty or self.isHungry or self.isBroke{
		do goto target: self.target speed: guest_speed;
		distance_travelled <- distance_travelled + 1;
		
		if( location distance_to(self.target) < 3){
			
			if creative2 and self.isBroke and !self.isThirsty and !self.isHungry{
				ask theBank{
					write "Gimme the bucks!";
					myself.money_level <- myself.original_money;
					myself.color <- #green;
					myself.dancing <- true;
					myself.isBroke <-false;
				}
			}
			else{
				self.isBroke <-false;
				ask self.target_shop{
					if creative1{
						if myself.isThirsty{
							if self.drinks > 0{
								self.drinks <- self.drinks - 1;
								myself.isThirsty <- false;
								myself.thirst_level <- myself.original_thirst;
								myself.drunk <- myself.drunk + 1;
								myself.color <- #green;
								myself.dancing <- true;
								myself.money_level <- myself.money_level - 2;
								
							} else{
								write "Sorry Out of Drinks!";
								Shop newshop;
								loop i from: 0 to: length(ShopList) -1 {
									newshop <- ShopList[i];
									if newshop != myself.target_shop{
										break;
									}
								}
								myself.target <- newshop.location;
								myself.target_shop <- newshop;
								self.drinks <- max_drinks;
							}
						}
						
						if myself.isHungry{
							if self.food > 0{
								self.food <- self.food - 1;
								myself.isHungry <- false;
								myself.hunger_level <- myself.original_hunger;
								myself.color <- #green;
								myself.dancing <- true;
								myself.money_level <- myself.money_level - 1;
								
							} else{
								write "Sorry Out of Food!";
								Shop newshop;
								loop i from: 0 to: length(ShopList) -1 {
									newshop <- ShopList[i];
									if newshop != myself.target_shop{
										break;
									}
								}
								myself.target <- newshop.location;
								myself.target_shop <- newshop;
								self.food <- max_food;
							}
						}
						
					}
					else{
						if myself.isThirsty{
							self.drinks <- self.drinks - 1;
							myself.isThirsty <- false;
							myself.thirst_level <- myself.original_thirst;
							myself.drunk <- myself.drunk + 1;
							myself.color <- #green;
							myself.dancing <- true;
						}
						
						if myself.isHungry{
							self.food <- self.food - 1;
							myself.isHungry <- false;
							myself.hunger_level <- myself.original_hunger;
							myself.color <- #green;
							myself.dancing <- true;
						}
					}
				}
				
			}
			
			}
		}
	}

experiment festival_info type: gui {
//	parameter "Number of guests: " var: nb_guests min: 1 max: 10 category: "Guest" ;
	output {
		display main_display {
			species guest aspect: base ;
			species Guard aspect: base ;
			species InfoCenter aspect: base ;
			species Shop aspect: base ;
			species Bank aspect: base;
		}
	}
}

 